<?php
while (true) {
    file_put_contents(dirname(__FILE__).'/worker.log', date('H:i:s').PHP_EOL, FILE_APPEND | LOCK_EX);
    sleep(1);
}