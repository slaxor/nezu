Nezu
====
Nezu is a rails inspired simple amqp app framework. Right now it is pretty much a work in progress though we hope that it will do the job here at talkyoo.net.
It has two major modes of usage:

  1. nezu new /path/to/your/app
    generates an app-skeleton

  2. (bundle exec) nezu run
    inside your app folder starts your application and subscribes all your consumers to their appropriate queues

  3. Start
     amqp-consume --queue="test.pong.dev" cat
     in other shell

  4. Do
     amqp-publish --routing-key=test.your_app_name.dev --body='{"__action":"ping","__reply_to":"test.pong.dev","test":23}'
     in 3rd shell, now you should see the result:
     {"test":23,"__action":"ping_result"}
     in the output of amqp-consume an debug messages in "nezu run" output

*BIGFATALPHAWARNING:*
 This hasn`t been fully tested yet. So if your working on a nuclear plant or so, go back to sleep this will be a lower risk

This Software is released under the Terms of General Public License. You can find a copy of it in this project in the file [gpl3.txt](gpl3.txt "GPLv3 Text")

