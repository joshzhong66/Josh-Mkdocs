
#19、美元与人民币汇率计算
def calc_exchange_rate(amt,source,target):
          #人民币与美元汇率 ：6.3486人民币 ≈  1美元
          # 6.3486:1
    if source == "CNY" and target == "USD":
        result = amt /6.3486
        return result

r = calc_exchange_rate(100, "CNY", "USD")

#r = calc_exchange_rate(100, "EUR", "USD") 
#如果实参"CNY"换成未定义的"EUR"（欧元），
#打印结果会为None,none在pythoon中代表不存在的含义