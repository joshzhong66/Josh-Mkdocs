import requests
import json
import os

CORP_ID = 'wwb7c33e9b0ac176de'
CORP_SECRET = 'l8jaLGXkpb4q8fmWmGj5hS9KsYVaSQ8BRHFFOjZWCzU'
AGENT_ID = '1000177'


def get_access_token(corp_id, corp_secret):
    url = f"https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid={corp_id}&corpsecret={corp_secret}"
    response = requests.get(url)
    data = response.json()
    return data['access_token']

def download_image(image_url, file_name):
    response = requests.get(image_url)
    with open(file_name, 'wb') as file:
        file.write(response.content)


def upload_image_to_wechat(access_token, file_path):
    upload_url = f"https://qyapi.weixin.qq.com/cgi-bin/media/upload?access_token={access_token}&type=image"
    files = {'media': open(file_path, 'rb')}
    response = requests.post(upload_url, files=files)
    result = response.json()
    print("Upload Image Response:", result)  # 调试语句，打印上传图片的响应内容
    
    if 'errcode' in result and result['errcode'] != 0:
        raise Exception(f"Error uploading image: {result['errmsg']} (Error code: {result['errcode']})")

    media_id = result.get("media_id")  # 使用 get 方法获取 media_id，避免 KeyError
    return media_id

def send_image_message(access_token, to_user, to_party, to_tag, agent_id, media_id):
    message_url = f"https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token={access_token}"
    message_data = {
        "touser": to_user,
        "toparty": to_party,
        "totag": to_tag,
        "msgtype": "image",
        "agentid": agent_id,
        "image": {
            "media_id": media_id
        },
        "safe": 0,
        "enable_duplicate_check": 0,
        "duplicate_check_interval": 1800
    }
    response = requests.post(message_url, json=message_data)
    return response.json()

def main():
    try:
        access_token = get_access_token(CORP_ID, CORP_SECRET)
        
        #image_url = "https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/05/21/1aee300652fd9c940ec14326d8abb97d-image-20240521112236631-eb0fa1.png"
        image_url = "https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/05/21/d7c1d979ff4671a626d67121908b417b-image-20240521111943481-5bed3b.png"
        file_name = "downloaded_image.png"
        download_image(image_url, file_name)
        
        media_id = upload_image_to_wechat(access_token, file_name)
        
        
        to_user = "31314" 
       
        to_party = "深圳市长亮科技股份有限公司 / 长亮科技Sunline.Tech / 信息服务中心Group.IT.Services.Center / 信息运维部"  # 替换为实际的部门ID
        # 如果没有标签，可以留空
        to_tag = ""  
        result = send_image_message(access_token, to_user, to_party, to_tag, AGENT_ID, media_id)
        
        print(json.dumps(result, indent=4))
        
        if os.path.exists(file_name):
            os.remove(file_name)
    
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
