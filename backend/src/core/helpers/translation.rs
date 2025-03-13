use fluent::FluentResource;
use fluent_bundle::concurrent::FluentBundle;
use fluent_bundle::FluentArgs;
use std::collections::HashMap;
use std::fs;
use unic_langid::LanguageIdentifier;

pub struct Translator {
    bundles: HashMap<String, FluentBundle<FluentResource>>,
}

impl Translator {
    pub fn new() -> Self {
        let mut bundles: HashMap<String, FluentBundle<FluentResource>> = HashMap::new();

        for lang in &["en", "fr"] {
            let path = format!("locales/{}.ftl", lang);
            if let Ok(content) = fs::read_to_string(&path) {
                if let Ok(resource) = FluentResource::try_new(content) {
                    let lang_id: LanguageIdentifier = lang.parse().expect("Invalid language ID");
                    let mut bundle = FluentBundle::new_concurrent(vec![lang_id]);
                    bundle
                        .add_resource(resource)
                        .expect("Failed to add resource");
                    bundles.insert(lang.to_string(), bundle);
                }
            }
        }

        Translator { bundles }
    }

    pub fn translate(&self, lang: &str, key: &str, args: Option<FluentArgs<'_>>) -> String {
        if let Some(bundle) = self.bundles.get(lang) {
            if let Some(msg) = bundle.get_message(key) {
                if let Some(pattern) = msg.value() {
                    let mut errors = vec![];
                    let translated = bundle.format_pattern(pattern, args.as_ref(), &mut errors);
                    return translated.to_string();
                }
            }
        }
        key.to_string()
    }
}
