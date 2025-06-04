import json
import sys

if __name__ == "__main__":
    with open(sys.argv[1], "r") as f:
        data = json.load(f)
    result = ""
    for key, value in data.items():
        if key == "files":
            for f in value:
                result += f"file:{f['file']}\n"
                for func in f["functions"]:
                    result += f"function:{func['start_line']},{1 if int(func['execution_count'])>0 else 0},{func['name']}\n"
                for line in f["lines"]:
                    result += f"lcount:{line['line_number']},{1 if int(line['count'])>0 else 0}\n"
    print(result)
