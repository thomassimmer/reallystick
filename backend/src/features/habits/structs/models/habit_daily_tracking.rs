use core::fmt;

use chrono::{DateTime, Duration, NaiveDate, Utc};
use serde::de::{self, MapAccess, Visitor};
use serde::{Deserialize, Deserializer, Serialize, Serializer};
use sqlx::postgres::types::PgInterval;
use sqlx::Row;
use sqlx::{postgres::PgRow, prelude::FromRow};

#[allow(non_snake_case)]
#[derive(Debug, Clone)]
pub struct HabitDailyTracking {
    pub id: uuid::Uuid,
    pub user_id: uuid::Uuid,
    pub habit_id: uuid::Uuid,
    pub day: NaiveDate,
    pub created_at: DateTime<Utc>,

    pub duration: Option<Duration>,
    pub quantity_per_set: Option<i32>,
    pub quantity_of_set: Option<i32>,
    pub unit: Option<String>,
    pub reset: bool,
}

#[allow(non_snake_case)]
#[derive(Debug, Clone)]
pub struct HabitDailyTrackingData {
    pub id: uuid::Uuid,
    pub user_id: uuid::Uuid,
    pub habit_id: uuid::Uuid,
    pub day: NaiveDate,

    pub duration: Option<Duration>,
    pub quantity_per_set: Option<i32>,
    pub quantity_of_set: Option<i32>,
    pub unit: Option<String>,
    pub reset: bool,
}

// Implement FromRow for mapping SQL rows to the Rust struct
impl<'r> FromRow<'r, PgRow> for HabitDailyTracking {
    fn from_row(row: &'r PgRow) -> Result<Self, sqlx::Error> {
        Ok(HabitDailyTracking {
            id: row.try_get("id")?,
            user_id: row.try_get("user_id")?,
            habit_id: row.try_get("habit_id")?,
            day: row.try_get("day")?,
            created_at: row.try_get("created_at")?,
            duration: {
                let pg_interval: Option<PgInterval> = row.try_get("duration")?;
                pg_interval.map(|interval| {
                    Duration::microseconds(interval.microseconds)
                        + Duration::days(interval.days as i64)
                        + Duration::days((interval.months as i64) * 30) // Approximate months as 30 days
                })
            },
            quantity_per_set: row.try_get("quantity_per_set")?,
            quantity_of_set: row.try_get("quantity_of_set")?,
            unit: row.try_get("unit")?,
            reset: row.try_get("reset")?,
        })
    }
}

impl HabitDailyTracking {
    pub fn to_habit_daily_tracking_data(&self) -> HabitDailyTrackingData {
        HabitDailyTrackingData {
            id: self.id,
            user_id: self.user_id,
            habit_id: self.habit_id,
            day: self.day,
            duration: self.duration,
            quantity_per_set: self.quantity_per_set,
            quantity_of_set: self.quantity_of_set,
            unit: self.unit.to_owned(),
            reset: self.reset,
        }
    }
}

// Custom implementation of Serialize
impl Serialize for HabitDailyTrackingData {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        use serde::ser::SerializeStruct;

        let mut state = serializer.serialize_struct("HabitDailyTrackingData", 9)?;
        state.serialize_field("id", &self.id)?;
        state.serialize_field("user_id", &self.user_id)?;
        state.serialize_field("habit_id", &self.habit_id)?;
        state.serialize_field("day", &self.day)?;

        // Serialize duration as seconds if it exists
        if let Some(duration) = &self.duration {
            state.serialize_field("duration", &duration.num_seconds())?;
        } else {
            state.serialize_field("duration", &None::<i64>)?;
        }

        state.serialize_field("quantity_per_set", &self.quantity_per_set)?;
        state.serialize_field("quantity_of_set", &self.quantity_of_set)?;
        state.serialize_field("unit", &self.unit)?;
        state.serialize_field("reset", &self.reset)?;
        state.end()
    }
}

impl<'de> Deserialize<'de> for HabitDailyTrackingData {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        #[derive(Deserialize)]
        #[serde(field_identifier, rename_all = "snake_case")]
        enum Field {
            Id,
            UserId,
            HabitId,
            Day,
            Duration,
            QuantityPerSet,
            QuantityOfSet,
            Unit,
            Reset,
        }

        struct HabitDailyTrackingDataVisitor;

        impl<'de> Visitor<'de> for HabitDailyTrackingDataVisitor {
            type Value = HabitDailyTrackingData;

            fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
                formatter.write_str("struct HabitDailyTrackingData")
            }

            fn visit_map<V>(self, mut map: V) -> Result<HabitDailyTrackingData, V::Error>
            where
                V: MapAccess<'de>,
            {
                let mut id = None;
                let mut user_id = None;
                let mut habit_id = None;
                let mut day = None;
                let mut duration = None;
                let mut quantity_per_set = None;
                let mut quantity_of_set = None;
                let mut unit = None;
                let mut reset = None;

                while let Some(key) = map.next_key()? {
                    match key {
                        Field::Id => id = Some(map.next_value()?),
                        Field::UserId => user_id = Some(map.next_value()?),
                        Field::HabitId => habit_id = Some(map.next_value()?),
                        Field::Day => day = Some(map.next_value()?),
                        Field::Duration => {
                            if let Some(seconds) = map.next_value::<Option<i64>>()? {
                                duration = Some(Duration::seconds(seconds));
                            }
                        }
                        Field::QuantityPerSet => quantity_per_set = map.next_value()?,
                        Field::QuantityOfSet => quantity_of_set = map.next_value()?,
                        Field::Unit => unit = map.next_value()?,
                        Field::Reset => reset = Some(map.next_value()?),
                    }
                }

                let id = id.ok_or_else(|| de::Error::missing_field("id"))?;
                let user_id = user_id.ok_or_else(|| de::Error::missing_field("user_id"))?;
                let habit_id = habit_id.ok_or_else(|| de::Error::missing_field("habit_id"))?;
                let day = day.ok_or_else(|| de::Error::missing_field("day"))?;
                let reset = reset.ok_or_else(|| de::Error::missing_field("reset"))?;

                Ok(HabitDailyTrackingData {
                    id,
                    user_id,
                    habit_id,
                    day,
                    duration,
                    quantity_per_set,
                    quantity_of_set,
                    unit,
                    reset,
                })
            }
        }

        const FIELDS: &[&str] = &[
            "id",
            "user_id",
            "habit_id",
            "day",
            "duration",
            "quantity_per_set",
            "quantity_of_set",
            "unit",
            "reset",
        ];
        deserializer.deserialize_struct(
            "HabitDailyTrackingData",
            FIELDS,
            HabitDailyTrackingDataVisitor,
        )
    }
}
