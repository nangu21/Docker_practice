from flask import Flask #flaskウェブサーバ(実働環境では使わない)

app = Flask(__name__)

@app.route('/')
def hello_docker():
    return 'Hello Docker!\n'

if __name__=='__main__':
    app.run(debug=True, host='0.0.0.0')