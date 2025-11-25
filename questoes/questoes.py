#!/usr/bin/env python3
import csv
import random
import sys
from pathlib import Path

# Cores ANSI
VERDE = "\033[92m"
VERMELHO = "\033[91m"
RESET = "\033[0m"

def load_questions(csv_path):
    questions = []
    with open(csv_path, newline='', encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            q = row.get("Question", "").strip()
            if not q:
                continue
            options = [
                row.get("Option 1", "").strip(),
                row.get("Option 2", "").strip(),
                row.get("Option 3", "").strip(),
                row.get("Option 4", "").strip(),
            ]
            correct = row.get("Correct Option", "").strip()
            questions.append({
                "question": q,
                "options": options,
                "correct": correct,
            })
    return questions

def ask_question(qdata, q_number):
    print(f"\n{q_number}. {qdata['question']}")

    # monta lista de opções com flag da correta
    options = [{"text": opt, "correct": (opt == qdata["correct"])}
               for opt in qdata["options"]]

    # embaralha alternativas
    random.shuffle(options)

    letters = ["a", "b", "c", "d"]
    for i, opt in enumerate(options):
        print(f"  {letters[i]}) {opt['text']}")

    # lê resposta (A–D ou 1–4)
    chosen_index = None
    while chosen_index is None:
        answer = input("Sua resposta (a-d): ").strip().lower() 
        if not answer:
            continue
        if answer in letters:
            chosen_index = letters.index(answer)
        elif answer in ["1", "2", "3", "4"]:
            chosen_index = int(answer) - 1
        else:
            print("Entrada inválida. Responda com a, b, c, d ou 1-4.")
            continue

        if chosen_index < 0 or chosen_index >= len(options):
            print("Opção fora do intervalo. Tente novamente.")
            chosen_index = None

    chosen_option = options[chosen_index]
    is_correct = chosen_option["correct"]

    # não mostra feedback agora, só no final
    return {
        "question": qdata["question"],
        "options": options,
        "chosen": chosen_option,
        "is_correct": is_correct,
    }

def main():
    # arquivo CSV: padrão questoes.csv ou passado na linha de comando
    if len(sys.argv) > 1:
        csv_path = Path(sys.argv[1])
    else:
        csv_path = Path("questoes.csv")

    if not csv_path.is_file():
        print(f"Arquivo de questoes não encontrado")
        print("Use: python questoes.py caminho/para/questoes.csv")
        sys.exit(1)

    questions = load_questions(csv_path)
    if not questions:
        print("Nenhuma questão encontrada no CSV.")
        sys.exit(1)

    num_questions = min(10, len(questions))
    selected = random.sample(questions, num_questions)

    print("=== Questionário de Sistemas Operacionais ===\n")
    
    results = []
    for i, q in enumerate(selected, start=1):
        res = ask_question(q, i)
        results.append(res)

    # resumo final
    print("\nPressione ENTER para ver o resultado final...")
    input()
    print("\033c", end="")  # limpa tela
    
    total_correct = sum(1 for r in results if r["is_correct"])
    print("\n=== Resultado ===")
    print(f"Acertos: {total_correct} de {len(results)} questões")
    print(f"Erros:   {len(results) - total_correct}")

    print("\nDetalhamento por questão:")
    for idx, r in enumerate(results, start=1):
        if r["is_correct"]:
            status = f"{VERDE}ACERTOU{RESET}"
        else: 
            status = f"{VERMELHO}ERROU{RESET}"

        print(f"{idx:02d}. {r['question']} {status}")

if __name__ == "__main__":
    main()

