# Datasets

This app ships with local datasets for offline operation.

## Included datasets

- Bible data: `assets/bible/*.json`
- Panic support responses: `assets/panic/panic_responses.jsonl`

## Policy

- Keep datasets in-repo while they are lightweight.
- If datasets become large, move them to scripted downloads under `scripts/dataset_tools/`.
- Validate schema compatibility before replacing dataset files.
