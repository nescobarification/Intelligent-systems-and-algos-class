class Algorithm:
    def __init__(self):
        pass

    def fit(self,X):
        pass

    def predict(self,X):
        pass

    # X: input needed for prediction
    # Y: good answer(output)
    def score(self,X,Y): # Accuracy
        num_of_valid_prediction = 0
        if len(X) == len(Y):
            print("Mauvaise taile")
            return
        else:
            for i in range(0,len(X)):
                if X[i] == Y[i]:
                    num_of_valid_prediction = num_of_valid_prediction + 1

        score =  num_of_valid_prediction/ len(X)

        return 'Accuracy {:09.4f}'.format(score)