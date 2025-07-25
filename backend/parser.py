
import re
def parse_mcqs(text):
    pattern = re.compile(r"Q\d+\.\s*(.*?)\nA\.\s*(.*?)\nB\.\s*(.*?)\nC\.\s*(.*?)\nD\.\s*(.*?)\nAnswer:\s*([A-D])", re.DOTALL)
    mcqs = []
    for match in pattern.finditer(text):
        q, a, b, c, d, ans = match.groups()
        options = [a.strip(), b.strip(), c.strip(), d.strip()]
        correct = options[ord(ans) - ord('A')]
        mcqs.append({"question": q.strip(), "options": options, "answer": correct})
    return mcqs
