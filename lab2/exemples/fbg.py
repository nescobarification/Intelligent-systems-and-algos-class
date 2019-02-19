import nltk
from nltk import grammar, parse
from nltk.parse.generate import generate

text = open("fbg.txt","r")

grammar = grammar.FeatureGrammar.fromstring(text)
tokens = 'these girls'.split()
parser = parse.FeatureEarleyChartParser(grammar)
trees = parser.parse(tokens)
for tree in trees: print(tree)

for sentence in generate(grammar, n=20):
       print(' '.join(sentence))
        