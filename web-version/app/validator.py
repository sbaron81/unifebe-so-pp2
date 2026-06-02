import subprocess
import yaml
import os

def run_command(command):
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, executable='/bin/bash')
        return result.stdout.strip()
    except Exception as e:
        return str(e)

class ActivityValidator:
    def __init__(self, tasks_file):
        with open(tasks_file, 'r') as f:
            data = yaml.safe_load(f)
            self.activities = data.get('activities', [])
            self.prerequisites = data.get('prerequisites', [])

    def get_prerequisites_status(self):
        results = []
        for pre in self.prerequisites:
            out = run_command(pre['check_command'])
            results.append({
                "id": pre['id'],
                "title": pre['title'],
                "status": out == "true"
            })
        return results

    def validate(self, activity_id, user_input=None):
        activity = next((a for a in self.activities if a['id'] == activity_id), None)
        if not activity:
            return False, "Atividade não encontrada."

        system_value = run_command(activity['check_command'])

        if activity['type'] == 'input_match':
            if user_input and user_input.strip() == system_value:
                return True, "✅ Sucesso!"
            return False, "❌ Valor incorreto. Tente novamente."
        
        elif activity['type'] == 'passive':
            expected = activity.get('expected_output', 'true')
            if system_value == expected:
                return True, "✅ Sucesso!"
            return False, "❌ Requisito não atendido."

        return False, "Tipo de validação desconhecido."
