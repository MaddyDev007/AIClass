
import re
def extract_2mark_questions(text):
    match = re.search(r"2-?mark questions?:\s*(.+?)(\n\n|16-?mark questions?:|$)", text, re.IGNORECASE | re.DOTALL)
    if match:
        return [line.strip("-•.\n ") for line in match.group(1).strip().split("\n") if line.strip()]
    return []

def extract_16mark_questions(text):
    match = re.search(r"16-?mark questions?:\s*(.+?)($|\n\n)", text, re.IGNORECASE | re.DOTALL)
    if match:
        return [line.strip("-•.\n ") for line in match.group(1).strip().split("\n") if line.strip()]
    return []
