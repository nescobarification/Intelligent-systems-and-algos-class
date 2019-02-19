import os, sys, getopt
from algorithms.cleaner import  *
from algorithms.ann import  *
from algorithms.knn import  *
import matplotlib.pyplot as plt
from tkinter.filedialog import askopenfilename

if __name__ == "__main__":
	algorithms_ = ["knn", "ann", "both"]
	algo = "ann"
	train = False
	plot = False
	predict = False

	try:
		opts, args = getopt.getopt(sys.argv[1:],"hm:tgp",["model=","train", "graph", "predict"])
	except getopt.GetoptError:
		print('main.py -m ann|knn|both ... [-t|--train] [-p|--predict] [-g|--graph]')
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print('main.py -m ann|knn|both ... [-t|--train] [-p|--predict] [-g|--graph]')
			sys.exit()
		elif opt in ("-m", "--model"):
			if arg not in algorithms_:
				print("Algorithm must be knn or ann")
				sys.exit()
			algo = arg
		elif opt in ("-t", "--train"):
			train = True
		elif opt in ("-g", "--graph"):
			plot = True
		elif opt in ("-p", "--predict"):
			predict = True

	if train:
		print("Veuillez choisir le fichier d'entrainement ")
		training_file = askopenfilename()

		x, x_test, y, y_test = clean(training_file)
		# x, x_test, y, y_test = clean(os.path.dirname(os.path.abspath(__file__)) + "/Dataset.csv")

	if algo == "ann":
		input_dim = 10
		hidden_dim = 5
		output_dim = 10

		nn = NeuralNetwork(input_dim, hidden_dim, output_dim, weights_file=(None if train else "weights_and_biaises.json"))
		if train:
			h = nn.fit(x, one_hot_encode(y), EPOCH=70)
			print("Training accuracy: %0.3f" % nn.score(x_test, y_test.values))

		if train or predict:
			print('Predictions\n')
		if train:
			print("Training predictions:")
			print(nn.predict(x_test))
		if predict:
			print("Veuillez choisir le fichier de predictions ")
			predict_file = askopenfilename()

			x_nolabel = clean(predict_file, noLabel = True)
			# x_nolabel = clean(os.path.dirname(os.path.abspath(__file__)) + "/Evaluations.csv", noLabel = True)
			print(nn.predict(x_nolabel))

		if plot:
			plt.title('NeuralNetwork Loss history')
			plt.plot(nn.history[0])
			plt.show()

	elif algo == "knn":
		k = 8
		knn = KNN2(k, 10, pickle_file=(None if train else "knn-{}-{}.pickle".format(k, 10)))
		if train:
			knn.fit(x.values, y.values)
			print("Training accuracy: %0.3f" % knn.score(x_test.values, y_test.values))
		if train or predict:
			print('Predictions\n')
		if train:
			print("Training predictions:")
			print(knn.predict(x_test.values))
		if predict:
			print("Veuillez choisir le fichier de predictions ")
			predict_file = askopenfilename()

			x_nolabel = clean(predict_file, noLabel = True)
			# x_nolabel = clean(os.path.dirname(os.path.abspath(__file__)) + "/Evaluations.csv", noLabel = True)
			print(knn.predict(x_nolabel.values))
		if plot:
			if not train:
				print('KNN need to training data to show best `k` value graph.')
			else:
				plt.title('Knn k-value/accuracy')
				plt.plot(knn.find_best_k(x_test.values, y_test.values))
				plt.show()

	elif algo == "both":
		k = 8
		knn = KNN2(k, 10, pickle_file=(None if False else "knn-{}-{}.pickle".format(k, 10)))
		input_dim = 10
		hidden_dim = 5
		output_dim = 10

		nn = NeuralNetwork(input_dim, hidden_dim, output_dim, weights_file=(None if train else "weights_and_biaises.json"))
		if train:
			knn.fit(x.values, y.values)
			nn.fit(x, one_hot_encode(y), EPOCH=70)
		if train or predict:
			print('Predictions\n')
		if train:
			nn_preds = nn.predict_proba(x_test)
			knn_preds = knn.predict_proba(x_test.values)

			preds = np.argmax(nn_preds + knn_preds, axis = 1)
			print("Training predictions:")
			print(preds)
		if predict:
			print("Veuillez choisir le fichier de predictions")
			predict_file = askopenfilename()

			x_nolabel = clean(predict_file, noLabel = True)
			# x_nolabel = clean(os.path.dirname(os.path.abspath(__file__)) + "/Evaluations.csv", noLabel = True)
			preds = np.argmax(knn.predict_proba(x_nolabel.values) + nn.predict_proba(x_nolabel.values), axis = 1)
			print(preds)
		if plot:
			if not train:
				print('KNN need to training data to show best `k` value graph.')
			else:
				plt.title('Knn k-value/accuracy')
				plt.plot(knn.find_best_k(x_test.values, y_test.values))
				plt.show()
			plt.title('NeuralNetwork Loss history')
			plt.plot(nn.history[0])
			plt.show()
