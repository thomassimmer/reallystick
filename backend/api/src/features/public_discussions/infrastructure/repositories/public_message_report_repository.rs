// PublicMessageReportRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::public_discussions::domain::entities::public_message_report::PublicMessageReport;
use crate::features::public_discussions::domain::repositories::public_message_report_repository::PublicMessageReportRepository;

pub struct PublicMessageReportRepositoryImpl {
    pool: PgPool,
}

impl PublicMessageReportRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        report: &PublicMessageReport,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO public_message_reports (
                id,
                reporter,
                message_id,
                created_at,
                reason
            )
            VALUES ( $1, $2, $3, $4, $5)
            "#,
            report.id,
            report.reporter,
            report.message_id,
            report.created_at,
            report.reason
        )
        .execute(executor)
        .await
    }

    pub async fn delete_with_executor<'a, E>(
        &self,
        report_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE FROM public_message_reports
            WHERE id = $1
            "#,
            report_id
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        report_id: Uuid,
        executor: E,
    ) -> Result<Option<PublicMessageReport>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PublicMessageReport,
            r#"
            SELECT *
            FROM public_message_reports
            WHERE id = $1
            "#,
            report_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_all_with_executor<'a, E>(
        &self,
        executor: E,
    ) -> Result<Vec<PublicMessageReport>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PublicMessageReport,
            r#"
            SELECT *
            FROM public_message_reports
            "#
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_by_reporter_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<Vec<PublicMessageReport>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PublicMessageReport,
            r#"
            SELECT pmr.*
            FROM public_messages pm
            JOIN public_message_reports pmr ON pm.id = pmr.message_id
            WHERE pmr.reporter = $1
            "#,
            user_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn delete_by_user_id_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE FROM public_message_reports
            WHERE reporter = $1
            "#,
            user_id,
        )
        .execute(executor)
        .await
    }

    pub async fn count_with_executor<'a, E>(&self, executor: E) -> Result<i64, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        let row = sqlx::query!(
            r#"
            SELECT COUNT(*) as count
            FROM public_message_reports
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl PublicMessageReportRepository for PublicMessageReportRepositoryImpl {
    async fn create(&self, report: &PublicMessageReport) -> Result<(), String> {
        self.create_with_executor(report, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete(&self, report_id: Uuid) -> Result<(), String> {
        self.delete_with_executor(report_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(&self, report_id: Uuid) -> Result<Option<PublicMessageReport>, String> {
        self.get_by_id_with_executor(report_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_all(&self) -> Result<Vec<PublicMessageReport>, String> {
        self.get_all_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_reporter(&self, user_id: Uuid) -> Result<Vec<PublicMessageReport>, String> {
        self.get_by_reporter_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String> {
        self.delete_by_user_id_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn count(&self) -> Result<i64, String> {
        self.count_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())
    }
}
