#!/usr/bin/env python3

# libraries and imports
# pip install langdetect
from langdetect import detect
from langdetect.lang_detect_exception import LangDetectException
import re
import numpy as np
import sys

# parsing from .srt format
def parse(input_text):
    # Regular expression to capture timestamps and the corresponding text between them
    pattern = re.compile(r"(\d{2}:\d{2}:\d{2},\d{3} --> \d{2}:\d{2}:\d{2},\d{3})\s*(.*?)\s*(?=\d{2}:\d{2}:\d{2},\d{3}|$)", re.DOTALL)

    timecodes = []
    lines = []

    # Find all matches for the pattern
    for match in re.finditer(pattern, input_text):
        timecodes.append(match.group(1))
        lines.append(match.group(2))

    return timecodes, lines

# more parsing from .srt format
def extract_sentences(input):
  with open(input, "r", encoding="utf-8") as f:
    text = f.read()
    text = text.strip().replace('\n', '')

  sentences = parse(text)[1]
  sentences = [re.sub(r'\d+$', '', s) for s in sentences]
  return sentences

# Determines if it is multilingual by using langdetect to check if three lines consecutively are the same language that is not English 
def is_multilingual(input):
  multilingualism = False
  for i in range(1, len(input)-1):
    try:
      if detect(input[i]) != "en" and detect(input[i - 1]) != "en" and detect(input[i]) == detect(input[i-1]) == detect(input[i+1]):
        multilingualism = True
        break
    except LangDetectException:
      continue

  return multilingualism

# Applies all functions above in one function
def detect_multilingual(input):
  sentences = extract_sentences(input)
  multilingualism = is_multilingual(sentences)
  return multilingualism

#applies to bash
if __name__ == "__main__":
    input_file = sys.argv[1]
    multilingual = detect_multilingual(input_file)
    print(multilingual)
