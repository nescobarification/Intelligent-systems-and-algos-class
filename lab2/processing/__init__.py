import pdb
import nltk
from nltk.sem.logic import LogicParser
import pprint

def tojess(sem,is_negation):


    fact = str(sem).replace('(', ' ').replace(',', ' ').replace(')', '').strip()
    if is_negation:
        fact = "not({})".format(fact)


    return "({})".format(fact)


def process(SEM):
    # parse string object to TLP type
    tlp = LogicParser(True)
    SEM = tlp.parse(SEM)
    expression_list = []
    # extract individual logic statements
    while type(SEM) is nltk.sem.logic.AndExpression:

        # parse unique entity
        expression_list.append(parse(SEM.second))
        SEM = SEM.first

    # process trailing logic statement
    expression_list.append(parse(SEM))
    return ([expression for expression in expression_list])

def parse(expr):

    is_negation =  type(expr) == nltk.sem.logic.NegatedExpression
    if is_negation:#Check if expression is negated
        expr = expr.negate()

    return tojess(expr,is_negation)

def clean_negation(sentence):
    return sentence.replace("n'", "n' ").replace("'", "")
