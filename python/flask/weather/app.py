from flask import Flask, render_template

app = Flask(__name__)

class WeatherData:
    def __init__(self, data):
        self.name = data['name']
        self.country = data['country']
        self.temp = data['temp']
        self.feels_like = data['feels_like']
        self.icon = f'https://s3-us-west-2.amazonaws.com/s.cdpn.io/162656/{data["icon"]}.svg'
        self.description = data['description']

@app.route('/')
def index():
    cities_data = []
    wd1 = WeatherData({
        'name': 'London',
        'country': 'UK',
        'temp': '12',
        'feels_like': '11',
        'icon': '10d',
        'description': 'Moderate rain'
    })
    cities_data.append(wd1)
    wd2 = WeatherData({
        'name': 'New York',
        'country': 'US',
        'temp': '20',
        'feels_like': '19',
        'icon': '01d',
        'description': 'Sunny'
    })
    cities_data.append(wd2)
    wd3 = WeatherData({
        'name': 'Shen Zhen',
        'country': 'CN',
        'temp': '20',
        'feels_like': '19',
        'icon': '01d',
        'description': 'Sunny'
    })
    cities_data.append(wd3)
    return render_template('weather.html', cities_data=cities_data)

if __name__ == "__main__":
    app.run()
