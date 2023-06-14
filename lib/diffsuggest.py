import itertools as it
import difflib as diff


def process_file(filename, process_with, delimiter=':', debug=False):
    def generate_suggestion(original_hunk_start,
                            original_hunk_len,
                            suggestion_buffer):
        suggestion_buffer = [l[1:] for l in suggestion_buffer if not l.startswith('-')]
        # удаляем кавычки, появившиеся после repr
        suggestion_text = repr("".join(suggestion_buffer))[1:-1]
        fmt = '{filename}{delimiter}{original_hunk_start}{delimiter}```suggestion:-0+{original_hunk_len}\\n{suggestion_text}```'
        return fmt.format(filename=filename,
                          delimiter=delimiter,
                          original_hunk_start=original_hunk_start,
                          original_hunk_len=original_hunk_len,
                          suggestion_text=suggestion_text)


    with open(filename, 'r') as f:
        original_lines = f.readlines()

    linted_filename = process_with(filename)
    with open(linted_filename, 'r') as f:
        formatted_lines = f.readlines()

    resulting_diff = list(diff.unified_diff(original_lines,
                                            formatted_lines,
                                            n=1))

    suggestion_buffer = []
    suggestion_lines = []
    for line, line_ahead in it.zip_longest(resulting_diff[2:],
                                           resulting_diff[3:],
                                           fillvalue=''):
        if debug:
            print(line, end='')
            continue
        if line.startswith('@'):
            original_hunk, linted_hunk = line.replace('@@','').rstrip().lstrip().split()
            original_hunk_start, original_hunk_len = [int(s) for s in original_hunk.split(',')]
            original_hunk_start = -original_hunk_start
            original_hunk_len -= 1
            continue
        if line_ahead.startswith('@') and suggestion_buffer:
            suggestion_buffer.append(line)
            suggestion_lines.append(generate_suggestion(original_hunk_start,
                                                        original_hunk_len,
                                                        suggestion_buffer))
            suggestion_buffer = []
            continue

        suggestion_buffer.append(line)

    if suggestion_buffer:
        suggestion_lines.append(generate_suggestion(original_hunk_start,
                                                    original_hunk_len,
                                                    suggestion_buffer))
    return suggestion_lines
