import csv
import numpy as np
import random
import pandas as pd
def clean(file_name, noLabel = False):
    data = []
    df = pd.read_csv(file_name, sep=";")

    # Delete rows with column values set to null
    df.dropna()

    # Print rows with column values set to null
    # print(df[df.isnull().any(axis=1)])
    # df[df.isnull().any(axis=1)]
    if not noLabel:
        data = remove_duplicates(df)
    else:
        data = pd.DataFrame(df)

    data = normalize(data, noLabel)

    # Reduction des attributs
    data = data.drop(["density"], axis=1)

    if noLabel:
        return data

    return train_test_split(data)

def normalize(df, noLabel = False):
    df_norm = (df - df.min()) / (df.max() - df.min())
    df_norm["pH"] = df["pH"] / 14 # Has a fixed range from 0 to 14
    df_norm["alcohol"] = df["alcohol"] / 100 # already a percentage
    if not noLabel:
        df_norm["quality"] = df["quality"]
    df = df_norm

    return df

def remove_duplicates(df):
    df_no_dup_1 = df.drop_duplicates()# Remove duplicate and keep one
    #print("First cut length:{}".format(len(df_no_dup_1)))
    df_no_dup_2 = df_no_dup_1.drop_duplicates(subset=df.columns.values[:-1])# Remove duplicates line with same input and different output
    #print("Second cut length:{}".format(len(df_no_dup_2)))

    return df_no_dup_2

def train_test_split(df, test_frac = .3, label_column = "quality"):
    # Stratified sampling on the label column. In our case it's "quality"
    grouped_df = df.groupby(label_column).apply(lambda x: x.sample(frac=test_frac))

    # return an array of booleans. True for each elemnts who will be in our test dataset
    index_in_test = df.index.isin(grouped_df.index.levels[1]) # .levels[0] = Groups ; .levels[1] = row indexes

    test_df = df.loc[index_in_test]
    # The ~ sign reverse the booleans values
    # Not sure if it works outside of pandas' dataframe
    train_df = df.loc[~index_in_test]

    # return the values in the x_train, x_test, y_train, y_test format.
    # Trying to replicate the format of
    # http://scikit-learn.org/stable/modules/generated/sklearn.model_selection.train_test_split.html
    return train_df[df.columns.values[:-1]], test_df[df.columns.values[:-1]], train_df[df.columns.values[-1]], test_df[df.columns.values[-1]]