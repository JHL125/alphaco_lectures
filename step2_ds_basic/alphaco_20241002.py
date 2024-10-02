#파일명 : alphaco_20241002.py

import pandas as pd
from pandas import DataFrame


from pandas import DataFrame

data = [
    ["037730", "3R", 1510],
    ["036360", "3SOFT", 1790],
    ["005670", "ACTS", 1185]
]

columns = ["종목코드", "종목명", "현재가"]
df = DataFrame(data=data, columns=columns)
df.set_index("종목코드", inplace=True)
df
#print(df)

#ascending=False : 내림차순
# asㅊending=False : 오름차순
#print(df.sort_values(by="종목명", ascending=False)) 
#print(df.sort_values(by="종목명", ascending=True)) 

# 행 인덱스를 기준으로 오름차순 정렬합니다.
#print(df.sort_index())#기본값 
#print(df.sort_index(ascending=False)) #역순(행인덱스 기준)

#인덱스 연산
# 합집합, 교집합, 차집합의 원리를 이용해서, 데이터 병합을 할 때 사용
#idx1 =pd.Index([1, 2, 3 ])
#idx2 = pd.Index([2, 3, 4])

#print(idx2.union(idx2)) ## 같은 값은 중복되기 때문에 제거하고 합친다.

# 교집합,, 겹치는 값
#print(idx1.intersection(idx2))

#차집합 # 답idx1에서 - 1
#print(idx1.difference(idx2))

#그룹바이 연산
#튜토리얼에 가면 그룹바이연산이 있음 , 과제로 다 해오기
from pandas import DataFrame

data = [
    ["2차전지(생산)", "SK이노베이션", 10.19, 1.29],
    ["해운", "팬오션", 21.23, 0.95],
    ["시스템반도체", "티엘아이", 35.97, 1.12],
    ["해운", "HMM", 21.52, 3.20],
    ["시스템반도체", "아이에이", 37.32, 3.55],
    ["2차전지(생산)", "LG화학", 83.06, 3.75]
]

columns = ["테마", "종목명", "PER", "PBR"]
df = DataFrame(data=data, columns=columns)
df
#print(df)
#print(type(df))
result = df.groupby("테마")[["PER","PBR"]]
#print(type(result))

#print(result, type(result))
9
#print(df.groupby("테마").get_group("2차전지(생산)"))
#print(df.groupby("테마").get_group("시스템반도체"))
#print(df.groupby("테마").get_group("해운"))

#파일 내보내기
#result = df.groupby("테마")[["PER","PBR"]].mean()
#df.to_excel('result.xlsx', index=False)

#데이터 불러오기
df= pd.read_excel("241002/ss_ex_1.xlsx", parse_dates=['일자'], index_col=0)
#print(df. head())

df = df.reset_index()
#print(df.head())

#print(df.info())

import pandas as pd
import numpy as np
#column 추가
df['분기'] = df['일자'].dt.quarter
df['연도'] = df['일자'].dt.year
df['월'] = df['일자'].dt.month
df['일'] = df['일자'].dt.day

print(df.head(1))

#데이터 줄이기
#result = df.groupby(['연도','월']).get_group((2021,2))
#print(result)
multiples = {
    "시가": "first",
    "저가" : min,
    "고가" : max,
    "종가" : 'last'
}
result = df.groupby(['연도', '월']).agg(multiples)
print(result)
print(result.reset_index())

#result = df.groupby(['연도', '월'])['시가'].mean()

#print(result)