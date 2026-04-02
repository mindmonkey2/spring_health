import re

def update_file(filename, task_desc):
    try:
        with open(filename, 'r') as f:
            content = f.read()

        if "## Current State" in content:
            content = re.sub(r'## Current State\n.*?(?=\n##|$)', f'## Current State\n{task_desc}', content, flags=re.DOTALL)
        elif "## Recent Changes" in content:
            content = re.sub(r'## Recent Changes\n.*?(?=\n##|$)', f'## Recent Changes\n{task_desc}', content, flags=re.DOTALL)

        with open(filename, 'w') as f:
            f.write(content)
        print(f"Updated {filename}")
    except FileNotFoundError:
        print(f"{filename} not found.")

task = "- Hotfix applied to `trainer_ajax_service.dart` to remove the dead `generateSessionPlans` method (Task H remnant). Unused imports (including firebase_ai) cleaned up to pass strict flutter analyze."

update_file("PROJECT_STATE.md", task)
update_file("current_state.md", task)
