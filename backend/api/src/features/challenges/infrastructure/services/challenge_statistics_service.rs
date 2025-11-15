// Challenge statistics service - handles complex statistics queries

use sqlx::PgPool;
use std::collections::HashSet;

use crate::features::challenges::domain::entities::challenge_statistics::ChallengeStatistics;
use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;

pub struct ChallengeStatisticsService {
    challenge_repo: ChallengeRepositoryImpl,
    pool: PgPool,
}

impl ChallengeStatisticsService {
    pub fn new(pool: PgPool) -> Self {
        Self {
            challenge_repo: ChallengeRepositoryImpl::new(pool.clone()),
            pool,
        }
    }

    pub async fn fetch_challenge_statistics(
        &self,
    ) -> Result<Vec<ChallengeStatistics>, sqlx::Error> {
        let mut transaction = self.pool.begin().await?;

        let challenges = self
            .challenge_repo
            .get_all_with_executor(&mut *transaction)
            .await?;

        let counts = sqlx::query!(
            r#"
                SELECT challenge_id, count(*) as "count!"
                FROM challenge_participations
                GROUP BY challenge_id
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let ages = sqlx::query!(
            r#"
                SELECT challenge_id, u.age_category, count(*) as "count!"
                FROM challenge_participations hp
                LEFT JOIN users u ON hp.user_id = u.id
                WHERE u.age_category IS NOT NULL
                GROUP BY challenge_id, u.age_category
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let activities = sqlx::query!(
            r#"
                SELECT challenge_id, u.activity, count(*) as "count!"
                FROM challenge_participations hp
                LEFT JOIN users u ON hp.user_id = u.id
                WHERE u.activity IS NOT NULL
                GROUP BY challenge_id, u.activity
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let countries = sqlx::query!(
            r#"
                SELECT challenge_id, u.country, count(*) as "count!"
                FROM challenge_participations hp
                LEFT JOIN users u ON hp.user_id = u.id
                WHERE u.country IS NOT NULL
                GROUP BY challenge_id, u.country
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let regions = sqlx::query!(
            r#"
                SELECT challenge_id, u.region, count(*) as "count!"
                FROM challenge_participations hp
                LEFT JOIN users u ON hp.user_id = u.id
                WHERE u.region IS NOT NULL
                GROUP BY challenge_id, u.region
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let financial_situations = sqlx::query!(
            r#"
                SELECT challenge_id, u.financial_situation, count(*) as "count!"
                FROM challenge_participations hp
                LEFT JOIN users u ON hp.user_id = u.id
                WHERE u.financial_situation IS NOT NULL
                GROUP BY challenge_id, u.financial_situation
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let genders = sqlx::query!(
            r#"
                SELECT challenge_id, u.gender, count(*) as "count!"
                FROM challenge_participations hp
                LEFT JOIN users u ON hp.user_id = u.id
                WHERE u.gender IS NOT NULL
                GROUP BY challenge_id, u.gender
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let childrens = sqlx::query!(
            r#"
                SELECT challenge_id, u.has_children, count(*) as "count!"
                FROM challenge_participations hp
                LEFT JOIN users u ON hp.user_id = u.id
                WHERE u.has_children IS NOT NULL
                GROUP BY challenge_id, u.has_children
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let educations = sqlx::query!(
            r#"
                SELECT challenge_id, u.level_of_education, count(*) as "count!"
                FROM challenge_participations hp
                LEFT JOIN users u ON hp.user_id = u.id
                WHERE u.level_of_education IS NOT NULL
                GROUP BY challenge_id, u.level_of_education
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let urban_areas = sqlx::query!(
            r#"
                SELECT challenge_id, u.lives_in_urban_area, count(*) as "count!"
                FROM challenge_participations hp
                LEFT JOIN users u ON hp.user_id = u.id
                WHERE u.lives_in_urban_area IS NOT NULL
                GROUP BY challenge_id, u.lives_in_urban_area
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let relations = sqlx::query!(
            r#"
                SELECT challenge_id, u.relationship_status, count(*) as "count!"
                FROM challenge_participations hp
                LEFT JOIN users u ON hp.user_id = u.id
                WHERE u.relationship_status IS NOT NULL
                GROUP BY challenge_id, u.relationship_status
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let creators = sqlx::query!(
            r#"
                SELECT c.id, u.username
                FROM challenges c
                LEFT JOIN users u ON c.creator = u.id
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        transaction.commit().await?;

        // Process results
        let mut statistics = Vec::new();

        for challenge in challenges {
            // Get participant count for the current challenge
            let participant_count = counts
                .iter()
                .find(|c| c.challenge_id == challenge.id)
                .map(|c| c.count)
                .unwrap_or(0);

            // Collect age statistics for the current challenge
            let age_data: HashSet<(String, i64)> = ages
                .iter()
                .filter(|a| a.challenge_id == challenge.id)
                .filter_map(|a| a.age_category.as_ref().map(|age| (age.clone(), a.count)))
                .collect();

            // Collect activity statistics for the current challenge
            let activity_data: HashSet<(String, i64)> = activities
                .iter()
                .filter(|a| a.challenge_id == challenge.id)
                .filter_map(|a| {
                    a.activity
                        .as_ref()
                        .map(|activity| (activity.clone(), a.count))
                })
                .collect();

            // Collect country statistics for the current challenge
            let country_data: HashSet<(String, i64)> = countries
                .iter()
                .filter(|c| c.challenge_id == challenge.id)
                .filter_map(|c| c.country.as_ref().map(|country| (country.clone(), c.count)))
                .collect();

            // Collect region statistics for the current challenge
            let region_data: HashSet<(String, i64)> = regions
                .iter()
                .filter(|r| r.challenge_id == challenge.id)
                .filter_map(|r| r.region.as_ref().map(|region| (region.clone(), r.count)))
                .collect();

            // Collect financial situation statistics for the current challenge
            let financial_situation_data: HashSet<(String, i64)> = financial_situations
                .iter()
                .filter(|f| f.challenge_id == challenge.id)
                .filter_map(|f| {
                    f.financial_situation
                        .as_ref()
                        .map(|fs| (fs.clone(), f.count))
                })
                .collect();

            // Collect gender statistics for the current challenge
            let gender_data: HashSet<(String, i64)> = genders
                .iter()
                .filter(|g| g.challenge_id == challenge.id)
                .filter_map(|g| g.gender.as_ref().map(|gender| (gender.clone(), g.count)))
                .collect();

            // Collect has_children statistics for the current challenge
            let children_data: HashSet<(String, i64)> = childrens
                .iter()
                .filter(|ch| ch.challenge_id == challenge.id)
                .filter_map(|ch| {
                    ch.has_children.as_ref().map(|children| {
                        (
                            if *children {
                                "Yes".to_string()
                            } else {
                                "No".to_string()
                            },
                            ch.count,
                        )
                    })
                })
                .collect();

            // Collect education statistics for the current challenge
            let education_data: HashSet<(String, i64)> = educations
                .iter()
                .filter(|e| e.challenge_id == challenge.id)
                .filter_map(|e| {
                    e.level_of_education
                        .as_ref()
                        .map(|edu| (edu.clone(), e.count))
                })
                .collect();

            // Collect urban area statistics for the current challenge
            let urban_area_data: HashSet<(String, i64)> = urban_areas
                .iter()
                .filter(|u| u.challenge_id == challenge.id)
                .filter_map(|u| {
                    u.lives_in_urban_area.as_ref().map(|urban| {
                        (
                            if *urban {
                                "Yes".to_string()
                            } else {
                                "No".to_string()
                            },
                            u.count,
                        )
                    })
                })
                .collect();

            // Collect relationship_status statistics for the current challenge
            let relationship_status_data: HashSet<(String, i64)> = relations
                .iter()
                .filter(|rel| rel.challenge_id == challenge.id)
                .filter_map(|rel| {
                    rel.relationship_status
                        .as_ref()
                        .map(|rel_status| (rel_status.clone(), rel.count))
                })
                .collect();

            let creator_username_data: String = creators
                .iter()
                .filter(|c| c.id == challenge.id)
                .map(|c| c.username.clone())
                .next()
                .unwrap_or_default()
                .unwrap_or_default();

            // Create a ChallengeStatistics entry
            statistics.push(ChallengeStatistics {
                challenge_id: challenge.id,
                participants_count: participant_count,
                top_ages: age_data,
                top_activities: activity_data,
                top_countries: country_data,
                top_financial_situations: financial_situation_data,
                top_gender: gender_data,
                top_has_children: children_data,
                top_levels_of_education: education_data,
                top_lives_in_urban_area: urban_area_data,
                top_regions: region_data,
                top_relationship_statuses: relationship_status_data,
                creator_username: creator_username_data,
            });
        }

        Ok(statistics)
    }
}
