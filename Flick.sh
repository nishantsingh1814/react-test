#!/bin/bash

export FLICK_PATH=$(pwd)
sudo -- sh -c  'echo "export FLICK_PATH='$FLICK_PATH'">>'$HOME'/.bash_profile'

source ~/.bash_profile
echo $FLICK_PATH
sudo apt-get install curl
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
echo 'Installing git, Python 3, and pip...'
# libfreetype6-dev ziblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk


sudo apt-get -yq install git python3.5.2 python3.5.2-dev libjpeg-dev libtiff5-dev zlib1g-dev > /dev/null 2>&1
sudo apt-get -yq install python3-pip
sudo apt-get -yq install curl
sudo apt-get install libexempi3
git clone  https://github.com/nishantsingh1814/Flick.git

# Install virtualenv / virtualenvwrapper
echo 'Installing and configuring virtualenv and virtualenvwrapper...'
sudo pip3 install --quiet virtualenvwrapper==4.7.0 Pygments==2.1.1

# Install django
echo 'Installing django'
sudo pip3 install django

sudo apt-get install supervisor
sudo service supervisor restart


sudo  echo "#!/bin/bash

echo $FLICK_PATH
cd $FLICK_PATH/Flick

npm run dev
source $FLICK_PATH/Flick/env/bin/activate
python3 $FLICK_PATH/Flick/flick/manage.py runserver 127.0.0.1:8000" >>$FLICK_PATH/Flick/bin/flick_server.sh 


sudo -- sh -c  'echo "[program:flick]
command =npm run dev ;source '$FLICK_PATH'/Flick/env/bin/activate; python3 '$FLICK_PATH'/Flick/flick/manage.py runserver 127.0.0.1:8000
directory='$FLICK_PATH'/Flick
stderr_logfile='$FLICK_PATH'/Flick/logs/err.log
stdout_logfile='$FLICK_PATH'/Flick/logs/out.log" >> /etc/supervisor/conf.d/flick.conf'

sudo -- sh -c  'echo "[program:celery]
command ='$FLICK_PATH'/Flick/env/bin/celery -A flick worker --loglevel=info --concurrency=10
directory='$FLICK_PATH'/Flick/flick
stderr_logfile='$FLICK_PATH'/Flick/logs/err.log
stdout_logfile='$FLICK_PATH'/Flick/logs/out.log">> /etc/supervisor/conf.d/celery.conf'

sudo -- sh -c  'echo "[program:flick_redis]
command=redis-server">> /etc/supervisor/conf.d/redis.conf'


sudo apt-get update
sudo apt-get install postgresql postgresql-contrib

sudo -u postgres -H -- psql -c "CREATE USER flick WITH PASSWORD 'flick';"
sudo -u postgres -H -- psql -c "CREATE DATABASE flick;"
sudo -u postgres -H -- psql -c "grant all privileges on database flick to flick;"


wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make
sudo cp src/redis-server /usr/local/bin/
sudo cp src/redis-cli /usr/local/bin/

cd ..

cd Flick
npm install
if [ ! -d "env" ]; then
    virtualenv env
fi
source env/bin/activate
pip3 install -r requirements.txt

cd flick

python3 manage.py migrate

sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start flick
sudo supervisorctl start celery
sudo supervisorctl start flick_redis
