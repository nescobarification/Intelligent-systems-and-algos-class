import math
import pickle
import pandas as pd
import numpy as np
from .algorithm import Algorithm

class KNN(Algorithm):
    def __init__(self,k):
        self.k = k
        self.headers = ["fixed acidity","volatile acidity","citric acid","residual sugar","chlorides","free sulfur dioxide"]
        self.class_column = ["quality"]
        self.data = []

    def fit(self, X, Y):  # Training
        # Take data and reduce it by using the headers defined
        self.data = pd.DataFrame(X,columns=self.headers)
        self.labels = pd.DataFrame(Y,columns=self.class_column)

    def eucledian_distance(self, current_wine, eval_wine):
        inner_value = 0
        for k in self.headers:
            inner_value += (eval_wine[k] - current_wine[k]) ** 2
        return math.sqrt(inner_value)

    def predict(self, wine_array):
        wine_array = pd.DataFrame(wine_array,columns=self.headers)
        return self.predict_proba(wine_array)


    def predict_proba(self, wine_array):
        total_proba_array = []
        for i in range(0, len(wine_array)):
            current_wine = wine_array.iloc[i]

            # Find the distance between current wine and every other wines
            distance_array = self.data.apply(lambda row: self.eucledian_distance(current_wine=current_wine,eval_wine=row), axis=1)

            # Create a new dataframe with distances.
            distance_frame = pd.DataFrame(data={"dist": distance_array, "idx": distance_array.index})
            distance_frame.sort_values("dist", inplace=True)

            #Standard probability array. Value at index X represents the associated probability
            # based on K nearest neighbors classes
            current_proba_array = [0.]*10
            for j in range (0, self.k):
                #For K nearest, assign X more % probability to corresponding class based on on quality class
                k_class = self.labels.loc[int(distance_frame.iloc[j]["idx"])][self.class_column]
                current_proba_array[int(k_class)] += (100/self.k)/100

            total_proba_array.append(current_proba_array)

        return total_proba_array
      
    def score(self, x, y):
        y_pred = self.predict(x)
        return float(np.sum(y_pred == y)) / len(x)

class KNN2(Algorithm):
    def __init__(self, k = 1, n_col = 11, pickle_file = None):
        self.k = k
        self.n_col = n_col
        self.pickle_file = pickle_file
        if self.pickle_file is not None:
            try:
                self.data = pickle.load(open(self.pickle_file, "rb"))
            except (OSError, IOError) as e:
                pass

    def fit(self, x_train, y_train):
        self.data = np.column_stack((x_train,y_train))
        if self.pickle_file is not None:
            pickle.dump(self.data, \
                open("knn-{}-{}.pickle".format(self.k, self.n_col), "wb"))

    def predict(self, x):
        return np.argmax(self.predict_proba(x), axis = 1)

    def predict_proba(self, x):
        all_probas = []
        for n in x:
            probas = np.unique(self._eucludian_dist(n)[:self.k, 1], return_counts = True)
            probas = np.array(probas)
            nneighbors_index = np.array(probas[0]).astype(int)
            i = np.array(probas[1])
            classes = np.array([0.] * 10)
            classes[nneighbors_index] = i / np.sum(i)
            all_probas.append(classes)
        return all_probas


    def score(self, x, y):
        y_pred = self.predict(x)
        return float(np.sum(y_pred == y)) / len(x)

    def _eucludian_dist(self, x):
        dist = []
        for i in range(0, len(self.data)):
            dist.append([np.linalg.norm(self.data[i, :self.n_col]-x), self.data[i, -1]])
        dist = np.array(dist)
        return dist[np.argsort(dist[:, 0])]

    def find_best_k(self, x, y, max_k = 10):
        old_k = self.k
        values = [0.]
        for i in range(1, max_k+1):
            self.k = i
            values.append(self.score(x, y))
        self.k = old_k
        return values
