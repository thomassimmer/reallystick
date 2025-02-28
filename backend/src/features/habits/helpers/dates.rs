use chrono::Duration;
use sqlx::postgres::types::PgInterval;

pub fn duration_to_pg_interval(duration: Option<Duration>) -> Option<PgInterval> {
    duration.map(|d| PgInterval {
        months: 0, // Duration doesn't track months
        days: 0,   // Duration doesn't track days
        microseconds: d.num_microseconds().unwrap_or(0),
    })
}
