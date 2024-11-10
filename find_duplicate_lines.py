from os import walk, path
from collections import defaultdict


def find_duplicate_lines(root_dir, extension=".nix"):
    lines_map = defaultdict(list)

    for dirpath, _, filenames in walk(root_dir):
        for filename in filenames:
            if not filename.endswith(extension):
                continue

            filepath = path.join(dirpath, filename)
            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    for line_num, line in enumerate(f, 1):
                        content = line.strip()
                        if content:
                            lines_map[content].append((filepath, line_num))
            except Exception as e:
                print(f"Error reading {filepath}: {e}")

    # Filter and sort duplicates by occurrence count
    duplicates = [
        (content, locations)
        for content, locations in lines_map.items()
        if len(locations) > 1
    ]
    duplicates.sort(key=lambda x: len(x[1]), reverse=True)

    print("Found duplicate lines (sorted by occurrences):\n" + "-" * 50)

    for content, locations in duplicates:
        print(f"\nDuplicate content ({len(locations)} occurrences): {content}")
        print("Found in:")
        for filepath, line_num in locations:
            print(f"  - {filepath}:line {line_num}")


if __name__ == "__main__":
    find_duplicate_lines(".")
