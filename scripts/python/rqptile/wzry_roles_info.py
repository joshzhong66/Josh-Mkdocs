# -*- coding: utf-8 -*-
import requests
import re
from bs4 import BeautifulSoup

# 打开文件
with open("英雄攻略.md", "w", encoding="utf-8") as file:

    URL = requests.get('https://pvp.qq.com/web201605/herolist.shtml')
    html = URL.content
    soup = BeautifulSoup(html, 'html.parser', from_encoding="utf-8")  # 解析器
    div_people_list = soup.find('ul', attrs={'class': 'herolist clearfix'})

    for a in div_people_list.find_all('li'):
        # 爬取人物详情链接
        text_1 = a.find('a')
        URL_2 = ('https://pvp.qq.com/web201605/' + text_1['href'])  # 链接

        # 脾气任务名称
        URL_3 = requests.get(f'{URL_2}')
        html_2 = URL_3.content  # 再次解析
        soup_2 = BeautifulSoup(html_2, 'html.parser', from_encoding="utf-8")  # 解析器
        text_2 = soup_2.find('h2', attrs={'class': 'cover-name'}).get_text()  # 名称

        # 英雄名称及链接
        file.write(f'------------------------------>>{text_2}<<------------------------------\n')
        file.write(text_2 + '\t人物详情链接：' + URL_2 + '\n')

        # 爬取任务伤害比例
        text_3 = soup_2.find('ul', attrs={'class': 'cover-list'})  # 伤害
        T = 0
        for text_4 in text_3.find_all('i', attrs={'class': 'ibar'}):
            r = text_4['style']
            T += 1
            # 获取属性伤害
            if T == 1:
                file.write('生存能力：' + ''.join(re.findall('width:(.*)', r)) + '\n')
            elif T == 2:
                file.write('\t\t攻击伤害：' + ''.join(re.findall('width:(.*)', r)) + '\n')
            elif T == 3:
                file.write('技能效果：' + ''.join(re.findall('width:(.*)', r)) + '\n')
            elif T == 4:
                file.write('\t\t上手难度：' + ''.join(re.findall('width:(.*)', r)) + '\n')

                # 皮肤获取
                text_5 = soup_2.find('ul', attrs={'class': 'pic-pf-list pic-pf-list3'})['data-imgname']  # 读取标签
                data = text_5.replace("&0", "").replace("|", "]  [").replace("&", "")  # 去除杂物
                new_string = ''.join([i for i in data if not i.isdigit()])  # 去除烦人的数字
                file.write(f'{text_2}的皮肤：[' + new_string + ']\n')

                # 铭文推荐
                text_6 = soup_2.find('ul', attrs={'class': 'sugg-u1'})['data-ming']
                data_2 = text_6.replace("|", "]  [")  # 替换

                # 铭文ID转换
                def mwtj(f):
                    mapping = {
                        1514: '梦魇', 3531: '心眼', 2520: '狩猎', 1504: '异变', 3514: '鹰眼',
                        2517: '隐匿', 1510: '无双', 2503: '贪婪', 3515: '心眼', 1512: '宿命',
                        2515: '调和', 3509: '虚空', 3516: '怜悯', 1501: '圣人', 3511: '献祭',
                        2512: '轮回', 2506: '兽痕', 1517: '凶兆', 1519: '祸源', 1503: '传承',
                        3503: '均衡', 2501: '长生', 1520: '红月', 2504: '夺萃', 1505: '纷争',
                        3518: '回声'
                    }
                    return mapping.get(f, '')

                # 读取铭文ID
                data_3 = int(data_2[0:][:4])
                data_4 = int(data_2[8:][:4])
                data_5 = int(data_2[16:][:4])
                # 打印铭文
                file.write('铭文搭配推荐：[' + mwtj(data_3) + ']  [' + mwtj(data_4) + ']  [' + mwtj(data_5) + ']\n')

                # 推荐召唤师技能
                def Z_C(L):
                    mapping = {
                        80115: '闪现', 80107: '净化', 80102: '治疗', 80108: '终结',
                        80121: '弱化', 80103: '眩晕', 80104: '惩击', 80109: '疾跑',
                        80110: '狂暴'
                    }
                    return mapping.get(L, '')

                skill = soup_2.find('div', attrs={'class': 'sugg-info2 info'})
                skill_list = skill.find('p', attrs={'id': 'skill3'})['data-skill']
                skill_2 = skill_list.replace("|", "     ")  # 替换
                Z_1 = int(skill_2[0:][:8])
                Z_2 = int(skill_2[7:][:8])
                file.write('召唤师技能推荐：[' + Z_C(Z_1) + '] 或 [' + Z_C(Z_2) + ']\n')

                # 推荐出装
                # 出装一
                cz_list_1 = soup_2.find('div', attrs={'class': 'equip-info l'})
                cz_text = cz_list_1.find('ul', attrs={'class': 'equip-list fl'})['data-item']

                # 出装二
                cz_list_2 = soup_2.find('div', attrs={'class': 'equip-bd'})
                cz_text_2 = cz_list_2.find_all('div', attrs={'class': 'equip-info l'})[1]
                cz_2 = cz_text_2.find('ul', attrs={'class': 'equip-list fl'})['data-item']

                def cztj(G):
                    mapping = {
                        1425: '急速战靴', 1126: '末世', 1137: '暗影战斧', 1138: '破军', 1155: '破晓',
                        1127: '名刀·司命', 1132: '泣血之刃', 1423: '冷静之靴', 1233: '回响之杖', 1235: '痛苦面具',
                        1232: '博学者之怒', 1727: '日暮之流', 1238: '贤者之书', 1240: '噬神之书', 1234: '凝冰之息',
                        1533: '贪婪之噬', 1422: '抵抗之靴', 13310: '冰痕之握', 1335: '魔女斗篷', 1129: '速击之枪',
                        1728: '金色圣剑', 1222: '血族之书', 1231: '虚无法杖', 1223: '光辉之剑', 1236: '巫术法杖',
                        1134: '宗师之力', 1131: '碎星锤', 1336: '极寒风暴', 1334: '不死鸟之眼', 1532: '巨人之握',
                        1426: '疾步之靴', 1332: '霸者重装', 1327: '反伤刺甲', 1421: '影忍之足', 1333: '不详征兆',
                        1337: '贤者的庇护', 1522: '巡守利斧', 1133: '无尽战刃', 1136: '影刃', 1721: '极影',
                        1722: '救赎之翼', 1331: '红莲斗篷', 1239: '辉月', 1523: '追击刀锋', 1424: '秘法之靴',
                        1135: '闪电匕首', 1724: '近卫荣耀', 1226: '圣杯', 1225: '进化水晶', 1531: '符文大剑',
                        1227: '炽热支配者', 1237: '时之预言', 11311: '纯净苍穹', 1521: '游击弯刀', 1328: '血魔之怒',
                        12211: '梦魇之牙', 1723: '奔狼纹章', 1338: '爆裂之甲'
                    }
                    return mapping.get(G, '')

                # 出装一 进行转换
                data_2 = cz_text.replace("|", "          ")  # 替换
                C_z_1 = int(data_2[0:][:7])
                C_z_2 = int(data_2[10:][:12])
                C_z_3 = int(data_2[22:][:15])
                C_z_4 = int(data_2[36:][:15])
                C_z_5 = int(data_2[50:][:16])
                C_z_6 = int(data_2[65:][:16])
                # 出装二 进行转换
                data_list2 = cz_2.replace("|", "          ")  # 替换
                C_z_2_1 = int(data_list2[0:][:7])
                C_z_2_2 = int(data_list2[10:][:12])
                C_z_2_3 = int(data_list2[22:][:15])
                C_z_2_4 = int(data_list2[36:][:15])
                C_z_2_5 = int(data_list2[50:][:16])
                C_z_2_6 = int(data_list2[65:][:16])
                # 打印出装一
                file.write('推荐出装一：[' + cztj(C_z_1) + ']  [' + cztj(C_z_2) + ']  [' + cztj(C_z_3) + ']  [' + cztj(C_z_4) + ']  [' + cztj(C_z_5) + ']  [' + cztj(C_z_6) + ']\n')
                # 打印出装二
                try:
                    file.write('推荐出装二：[' + cztj(C_z_2_1) + ']  [' + cztj(C_z_2_2) + ']  [' + cztj(C_z_2_3) + ']  [' + cztj(C_z_2_4) + ']  [' + cztj(C_z_2_5) + ']  [' + cztj(C_z_2_6) + ']\n')
                except:
                    file.write('推荐出装二：[' + cztj(C_z_2_1) + ']  [' + cztj(C_z_2_2) + ']  [' + cztj(C_z_2_3) + ']  [' + cztj(C_z_2_4) + ']  [' + cztj(C_z_2_5) + ']\n')

                # 搭配英雄推荐
                dp = soup_2.find('div', attrs={'class': 'hero-info-box'})
                H = 0
                for TTT in range(3):
                    dp_list_1 = dp.find_all('div', attrs={'class': 'hero-info l info'})[H].find('a')['href']
                    URL_4 = ('https://pvp.qq.com/web201605/herodetail/' + dp_list_1)  # 链接
                    URL_5 = requests.get(f'{URL_4}')
                    html_3 = URL_5.content  # 再次解析
                    soup_3 = BeautifulSoup(html_3, 'html.parser', from_encoding="utf-8")  # 解析器
                    text_7 = soup_3.find('h2', attrs={'class': 'cover-name'}).get_text()  # 搭档一

                    dp_list_2 = dp.find_all('div', attrs={'class': 'hero-info l info'})[H].find_all('a')[1]['href']
                    URL_5 = ('https://pvp.qq.com/web201605/herodetail/' + dp_list_2)  # 链接
                    URL_5 = requests.get(f'{URL_5}')
                    html_4 = URL_5.content  # 再次解析
                    soup_4 = BeautifulSoup(html_4, 'html.parser', from_encoding="utf-8")  # 解析器
                    text_8 = soup_4.find('h2', attrs={'class': 'cover-name'}).get_text()  # 搭档二
                    H += 1
                    if H == 1:  # 最佳搭档
                        file.write('最佳搭档：[' + text_7 + ']  [' + text_8 + ']\n')
                    elif H == 2:  # 压制英雄
                        file.write('压制英雄：[' + text_7 + ']  [' + text_8 + ']\n')
                    elif H == 3:  # 被压制英雄
                        file.write('被压制英雄：[' + text_7 + ']  [' + text_8 + ']\n\n')
                        H = 0

                    if H == 4:
                        H = 0
                        pass
            else:
                if T == 5:
                    T = 0
                else:
                    pass
