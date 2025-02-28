use core::fmt;

use chrono::{Duration, NaiveDate};
use serde::{
    de::{self, MapAccess, Visitor},
    Deserialize, Deserializer,
};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetHabitDailyTrackingParams {
    pub habit_daily_tracking_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdateHabitDailyTrackingParams {
    pub habit_daily_tracking_id: Uuid,
}

pub struct HabitDailyTrackingUpdateRequest {
    pub day: NaiveDate,
    pub duration: Option<Duration>,
    pub quantity_per_set: Option<i32>,
    pub quantity_of_set: Option<i32>,
    pub unit: Option<String>,
    pub reset: bool,
}

pub struct HabitDailyTrackingCreateRequest {
    pub habit_id: uuid::Uuid,
    pub day: NaiveDate,
    pub duration: Option<Duration>,
    pub quantity_per_set: Option<i32>,
    pub quantity_of_set: Option<i32>,
    pub unit: Option<String>,
    pub reset: bool,
}

impl<'de> Deserialize<'de> for HabitDailyTrackingUpdateRequest {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        #[derive(Deserialize)]
        #[serde(field_identifier, rename_all = "snake_case")]
        enum Field {
            Day,
            Duration,
            QuantityPerSet,
            QuantityOfSet,
            Unit,
            Reset,
        }

        struct HabitDailyTrackingUpdateRequestVisitor;

        impl<'de> Visitor<'de> for HabitDailyTrackingUpdateRequestVisitor {
            type Value = HabitDailyTrackingUpdateRequest;

            fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
                formatter.write_str("struct HabitDailyTrackingUpdateRequest")
            }

            fn visit_map<V>(self, mut map: V) -> Result<HabitDailyTrackingUpdateRequest, V::Error>
            where
                V: MapAccess<'de>,
            {
                let mut day = None;
                let mut duration = None;
                let mut quantity_per_set = None;
                let mut quantity_of_set = None;
                let mut unit = None;
                let mut reset = None;

                while let Some(key) = map.next_key()? {
                    match key {
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

                let day = day.ok_or_else(|| de::Error::missing_field("day"))?;
                let reset = reset.ok_or_else(|| de::Error::missing_field("reset"))?;

                Ok(HabitDailyTrackingUpdateRequest {
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
            "day",
            "duration",
            "quantity_per_set",
            "quantity_of_set",
            "unit",
            "reset",
        ];
        deserializer.deserialize_struct(
            "HabitDailyTrackingUpdateRequest",
            FIELDS,
            HabitDailyTrackingUpdateRequestVisitor,
        )
    }
}

impl<'de> Deserialize<'de> for HabitDailyTrackingCreateRequest {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        #[derive(Deserialize)]
        #[serde(field_identifier, rename_all = "snake_case")]
        enum Field {
            HabitId,
            Day,
            Duration,
            QuantityPerSet,
            QuantityOfSet,
            Unit,
            Reset,
        }

        struct HabitDailyTrackingCreateRequestVisitor;

        impl<'de> Visitor<'de> for HabitDailyTrackingCreateRequestVisitor {
            type Value = HabitDailyTrackingCreateRequest;

            fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
                formatter.write_str("struct HabitDailyTrackingCreateRequest")
            }

            fn visit_map<V>(self, mut map: V) -> Result<HabitDailyTrackingCreateRequest, V::Error>
            where
                V: MapAccess<'de>,
            {
                let mut habit_id = None;
                let mut day = None;
                let mut duration = None;
                let mut quantity_per_set = None;
                let mut quantity_of_set = None;
                let mut unit = None;
                let mut reset = None;

                while let Some(key) = map.next_key()? {
                    match key {
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

                let habit_id = habit_id.ok_or_else(|| de::Error::missing_field("habit_id"))?;
                let day = day.ok_or_else(|| de::Error::missing_field("day"))?;
                let reset = reset.ok_or_else(|| de::Error::missing_field("reset"))?;

                Ok(HabitDailyTrackingCreateRequest {
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
            "habit_id",
            "day",
            "duration",
            "quantity_per_set",
            "quantity_of_set",
            "unit",
            "reset",
        ];
        deserializer.deserialize_struct(
            "HabitDailyTrackingCreateRequest",
            FIELDS,
            HabitDailyTrackingCreateRequestVisitor,
        )
    }
}
