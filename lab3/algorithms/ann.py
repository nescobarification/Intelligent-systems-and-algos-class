import math
import json
import numpy as np
from .algorithm import Algorithm

class NeuralNetwork(Algorithm):
    def __init__(self, input_dim, hidden_dim, output_dim, learning_rate = 0.02, weights_file = None):
        self.input_dim = input_dim
        self.hidden_dim = hidden_dim
        self.output_dim = output_dim
        self.learning_rate = learning_rate

        self.weights_file = weights_file

        np.random.seed(0)

        self.model = None
        self.history = [[], []]
        if self.weights_file is not None and self.model is None:
            with open(self.weights_file, 'r') as f:
                m = json.load(f)
                self.model = m
                self.history[0] = m['history']

    def fit(self, x_train, y_train, EPOCH = 2000):
        m = self.model
        try:
            W1, W2, W3, b1, b2, b3, self.history = m['w1'], m['w2'], m['w3'], m['b1'], m['b2'], m['b3'], m['history']
        except (NameError, TypeError):
            W1 = np.random.uniform(size=(self.input_dim, int(round(self.input_dim/2))))
            W2 = np.random.uniform(size=(int(round(self.input_dim/2)), self.hidden_dim))
            W3 = np.random.uniform(size=(self.hidden_dim, self.output_dim))
            b1 = np.zeros(int(round(self.input_dim/2)))
            b2 = np.zeros(self.hidden_dim)
            b3 = np.zeros(self.output_dim)

        d1 = np.empty((x_train.shape[0], int(round(self.input_dim/2))))
        d2 = np.empty((x_train.shape[0], self.hidden_dim))
        do = np.empty((x_train.shape[0], self.output_dim))

        self.model = {'w1': W1, 'b1': b1, 'w2': W2, 'b2': b2, 'w3': W3, 'b3': b3}

        for i in range(EPOCH):
            W1, W2, W3, b1, b2, b3 = self.model['w1'], self.model['w2'], self.model['w3'], \
                self.model['b1'], self.model['b2'], self.model['b3']
            l1 = np.dot(x_train, W1) + b1
            l1 = self._activation('relu', l1)
            l2 = np.dot(l1, W2) + b2
            l2 = self._activation('relu', l2)
            l3 = np.dot(l2, W3) + b3
            # l3 = self._activation('softmax', l3)

            self.model = {'w1': W1, 'b1': b1, 'w2': W2, 'b2': b2, 'w3': W3, 'b3': b3}

            # ===> [ADD BACKPROPAGATION HERE] <===
            d1, d2, do, error = self._backpropagation(x_train, y_train, l1, l2, l3, [d1, d2, do])

            if error <= 0:
                return self.history
        return self.history

    def predict(self, x):
        return np.argmax(self.predict_proba(x), axis=1)

    def predict_proba(self, x):
        W1, W2, W3, b1, b2, b3 = self.model['w1'], self.model['w2'], self.model['w3'], \
            self.model['b1'], self.model['b2'], self.model['b3']

        l1 = np.dot(x, W1) + b1
        l1 = self._activation('relu', l1)
        l2 = np.dot(l1, W2) + b2
        l2 = self._activation('relu', l2)
        l3 = np.dot(l2, W3) + b3
        y_pred = self._activation('softmax', l3)

        return y_pred

    def _activation(self, func_name, tensor, use_derivative=False):
        activations = {
            'tanh': lambda x: np.tanh(x),
            'relu': lambda x: x * (x > 0),
            'sigmoid': lambda x: 1.0/(1.0 + np.exp(-x)),
            'softmax': lambda x: self._softmax(x)
        }

        d_activations = {
            'tanh': lambda x: 1. - x * x,
            'relu': lambda x: 1. * (x > 0),
            'sigmoid': lambda x: x * (1. - x),
            'softmax': lambda x: self._dsoftmax(x)
        }

        if func_name in activations:
            if use_derivative:
                return d_activations[func_name](tensor)
            else:
                return activations[func_name](tensor)
        return None

    def _softmax(self, x):
        e = np.exp(x - np.max(x))
        dist = e / np.sum(e)
        return dist
    def _dsoftmax(self, x):
        e = np.exp(x - np.max(x))
        dist = e / np.sum(e)
        return dist

    def _backpropagation(self, x, y, l1, l2, y_output, deltas):
        delta_h1, delta_h2, delta_output = deltas
        delta_output = (y - y_output)

        error = np.mean(np.abs(delta_output))

        if not math.isnan(error) or error >= 0:
            self.history[0].append(error)

        delta_h2[:] = self._activation('relu', l2, True) * np.dot(delta_output, self.model['w3'].T)
        delta_h1[:] = self._activation('relu', l1, True) * np.dot(delta_h2, self.model['w2'].T)

        self.model['w3'] += self.learning_rate * np.dot(l2.T, delta_output)
        self.model['b3'] += self.learning_rate * np.mean(delta_output, axis=0)
        self.model['w2'] += self.learning_rate * np.dot(l1.T, delta_h2)
        self.model['b2'] += self.learning_rate * np.mean(delta_h2, axis=0)
        self.model['w1'] += self.learning_rate * np.dot(x.T, delta_h1)
        self.model['b1'] += self.learning_rate * np.mean(delta_h1, axis=0)

        for k in self.model:
            self.model[k][np.isnan(self.model[k])] = 0.9 * np.random.random_sample()

        return delta_h1, delta_h2, delta_output, error

    def score(self, x, y):
        y_pred = self.predict(x)
        if len(y_pred) != len(y):
            print('Length of y_pred != length of y')
            return False
        n = 0.
        for i in range(len(y_pred)):
            if y_pred[i] == y[i]:
                n += 1.
        return n/y_pred.shape[0]

def one_hot_encode(y, NUM_CLASSES = 10):
    targets = np.array([y]).reshape(-1)
    one_hot_targets = np.eye(NUM_CLASSES)[targets]

    return one_hot_targets
