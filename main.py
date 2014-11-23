import traceback, sys, re
from flask import Flask, render_template, request
app = Flask(__name__)
app.config['DEBUG'] = True


@app.route('/')
def root():
   return render_template('index.html')

@app.route('/subscribe/', methods=['GET', 'POST'])
def subscribe():
   address = request.form['address']
   email = request.form['email']
   e_wf  = re.match(r"[^@]+@[^@]+\.[^@]+",email)
   a_wf = (address != "")
   if e_wf and a_wf:
      with open('subscribers.csv', 'a') as f:
         f.write(email + "," + address)
      # mailjet shit
      return render_template('index.html', msg = "Successfully signed up!")
   else:
      return render_template('index.html', msg = "Please enter a valid email and address.")

if __name__ == '__main__':
   app.run()
