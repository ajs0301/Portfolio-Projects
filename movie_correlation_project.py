# import libraries
import pandas as pd
import numpy as np
import seaborn as sns

import matplotlib.pyplot as plt

# Read in the data
df = pd.read_csv(r'C:\Users\adria\OneDrive\Documents\Adrian\Developer\Portfolio Project - Alex The Analyst\Project 4 - Correlation in Python\movies.csv')

# Check for missing data
for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} : {}%'.format(col, pct_missing))

# Check data types of columns
print(df.dtypes)

# Change data type of 'budget' and 'gross' column to int64
df['budget'] = df['budget'].fillna(0).astype('int64')
df['gross'] = df['gross'].fillna(0).astype('int64')

# Create the correct year released column 
df['correct_yr'] = df['released'].str.split().str[2]

print(df.sort_values(by=['gross'], inplace=False, ascending=False))

pd.set_option("display.max_rows", None)

# Drop duplicates in data
print(df['company'].drop_duplicates().sort_values(ascending=False))

# Scatter plot of budget vs gross

#fig, ax = plt.subplots()

x=df['budget']
y=df['gross']
plt.style.use('ggplot')
plt.title('Budget vs. Gross Earnings')
plt.xlabel('Budget')
plt.ylabel('Gross Earnings')
plt.scatter(x, y)
z = np.polyfit(x, y, 1)
p = np.poly1d(z)
plt.plot(x, p(x), color="purple", linewidth=2, linestyle="--", label="Linear Trendline")
#plt.show()

print(f"Linear Trendline: y = {p[1]:.6f}x + {p[0]:.6f}")
print(f"Linear Trendline: y = {p(1)-p(0):.6f}x + {p(0):.6f}")

sns.regplot(x='budget',y='gross',data=df, scatter_kws={'color':'red'}, line_kws={'color':'blue'})
#plt.show()

print(df.corr(method='pearson', numeric_only=True))
correlation_matrix = df.corr(method='pearson', numeric_only=True)
sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation matrix for numeric features')
plt.xlabel('Movie features')
plt.ylabel('Movie features')
plt.show()

print(df.head())
# Look at company which is not numeric
df_numerized = df.copy()

for col_name in df_numerized.columns:
    if (df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes

print(df_numerized.head())

print(df_numerized.corr(method='pearson', numeric_only=True))
correlation_matrix = df_numerized.corr(method='pearson', numeric_only=True)
sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation matrix for numeric features')
plt.xlabel('Movie features')
plt.ylabel('Movie features')
plt.show()

pairs = correlation_matrix.unstack().sort_values(ascending=False)
print(pairs)

high_cor = pairs[(pairs)>0.5]
print(high_cor)