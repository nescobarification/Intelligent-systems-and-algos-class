#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import processing
from nltk import load_parser, draw

cp = load_parser('./grammaire.fcfg', trace=0)

with open("scenario.txt","r") as text:
    scenario = text.read()
open("facts.clp", 'w') # Clean Jess file

facts = []

for sentence in scenario.split("\n"):
    try:
        if not sentence : continue

        if sentence[0] == "#": continue #IGNORE THOSE LINES, FOR THEY ARE COMMENTS
        if "." in sentence: sentence = sentence[:-1] #REMOVE "." at end of line
        print("\nSENTENCE: {0}".format(sentence))

        sentence = processing.clean_negation(sentence)
        tokens = sentence.split()
        trees = list(cp.parse(tokens))# arbre base sur les mots de la grammaire

        if (len(trees) > 1):
            print('Is Ambiguous !!!')
        for tree in trees:
            # draw.tree.draw_trees(tree) # Draw tree on python window
            sem = tree.label()["SEM"]
            facts = processing.process(str(sem))
            for fact in facts:
                print(fact)

                with open("facts.clp","a") as text:
                    text.write(fact + '\n')
    except:
        continue
