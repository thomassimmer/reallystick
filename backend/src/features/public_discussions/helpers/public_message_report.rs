use sqlx::{postgres::PgQueryResult, PgConnection};
use uuid::Uuid;

use crate::features::public_discussions::structs::models::public_message_report::PublicMessageReport;

pub async fn get_message_reports(
    conn: &mut PgConnection,
) -> Result<Vec<PublicMessageReport>, sqlx::Error> {
    sqlx::query_as!(
        PublicMessageReport,
        r#"
        SELECT *
        FROM public_message_reports
        "#,
    )
    .fetch_all(conn)
    .await
}

pub async fn get_user_message_reports(
    conn: &mut PgConnection,
    user_id: Uuid,
) -> Result<Vec<PublicMessageReport>, sqlx::Error> {
    sqlx::query_as!(
        PublicMessageReport,
        r#"
        SELECT pmr.*
        FROM public_messages pm
        JOIN public_message_reports pmr ON pm.id = pmr.message_id
        WHERE pmr.reporter = $1;
        "#,
        user_id,
    )
    .fetch_all(conn)
    .await
}

pub async fn create_public_message_report(
    conn: &mut PgConnection,
    public_message_report: PublicMessageReport,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        PublicMessageReport,
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
        public_message_report.id,
        public_message_report.reporter,
        public_message_report.message_id,
        public_message_report.created_at,
        public_message_report.reason
    )
    .execute(conn)
    .await
}

pub async fn delete_public_message_report(
    conn: &mut PgConnection,
    id: Uuid,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        PublicMessageReport,
        r#"
        DELETE FROM public_message_reports
        WHERE id = $1
        "#,
        id,
    )
    .execute(conn)
    .await
}

pub async fn get_public_message_report_by_id(
    conn: &mut PgConnection,
    id: Uuid,
) -> Result<Option<PublicMessageReport>, sqlx::Error> {
    sqlx::query_as!(
        PublicMessageReport,
        r#"
        SELECT *
        from public_message_reports
        WHERE id = $1 
        "#,
        id,
    )
    .fetch_optional(conn)
    .await
}
