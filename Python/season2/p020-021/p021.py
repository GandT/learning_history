# coding: UTF-8
"""
　2018.4.20
　バブルソート
"""

def bubble(ln):
  n = 0 # 交換回数を返す

  for roop in range(len(ln) - 1):
    for i in range(len(ln) - 1):
      if(ln[i] > ln[i+1]):
        temp = ln[i+1]
        ln[i+1] = ln[i]
        ln[i] = temp
        n += 1
    
  return n

a = [10,3,6,4,7,8,2,9,5,1]
print(a)
print(bubble(a))
print(a)