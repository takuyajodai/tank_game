//ソケット通信のためのライブラリを読み込み
import processing.net.*;
Client client;

//プレイヤー2の情報(クライアント)
float c_mouseX, c_mouseY;

//クライアント側の入力(キーの同時入力のため仕方がない)
int c_keyCodeR;
int c_keyCodeL;
int c_keyCodeU;
int c_keyCodeD;

boolean keyBoolR;
boolean keyBoolL;
boolean keyBoolU;
boolean keyBoolD;

//ポート番号を指定
int port = 20000;

//サーバから読み込むデータ
float spx =width*0.2, spy = height*0.5, spr = 15, spa = 0, cpx = width*0.8, cpy = height*0.5, cpr = 15, cpa = 0;
boolean spd = true, cpd = true;
int sph = 10, sphm = 10, cph = 10, cphm = 10;

//ゲームの状態遷移(0=タイトル, 1=ゲーム, 2=クリア)
int scene;

//サーバのアドレス
//127.0.0.1はローカルマシン
String serverAdder = "127.0.0.1";

//玉の格納
//ArrayList<Ball> ball;

//ボールの状態をクライアントに送る用(消されたときのArrayの添字を持つ
String msg_ball = ""; 


void show_s() {
  if(spd) {
    if(sph < 1) {
      spd = false;
    }
    //サーバプレイヤーの外枠
    stroke(50, 50, 50);
    strokeWeight(4);
    fill(100);
    ellipse(spx, spy, spr, spr);

    //HPバー
    translate(spx, spy);
    stroke(10);
    strokeWeight(2);
    //全体バー
    fill(10,30,30);
    rect(-30,-60,60,13); 
    //減算バー
    fill(30,50,90);
    rect(-30,-60,60*(float(sph)/float(sphm)),13); 
    translate(-spx, -spy);

    //始点
    translate(spx, spy);
    rotate(spa);
    stroke(50, 50, 50);
    strokeWeight(7);
    line(spr, 0, spr+15, 0);
    
    rotate(-spa);
    translate(-spx, -spy);
  }
}
  
void show_c() {
  if(cpd) {
    if(cph < 1) {
      cpd = false;
    }
    //クライアントプレイヤーの外枠
    stroke(0, 80, 50);
    strokeWeight(4);
    fill(100);
    ellipse(cpx, cpy, cpr, cpr);

    //HPバー
    translate(cpx, cpy);
    stroke(10);
    strokeWeight(2);
    //全体バー
    fill(10,30,30);
    rect(-30,-60,60,13); 
    //減算バー
    fill(30,50,90);
    rect(-30,-60,60*(float(cph)/float(cphm)),13); 
    translate(-cpx, -cpy);

      
    //照準の回転(クライアント)(クライアントから入力を受け付ける)
    cpa = atan2(mouseY - cpy, mouseX - cpx);
    //始点
    translate(cpx, cpy);
    rotate(cpa);
    stroke(0, 80, 50);
    strokeWeight(7);
    line(cpr, 0, cpr+15, 0);
    rotate(-cpa);
    translate(-cpx, -cpy);
  }

}


void setup() {
  //指定されたアドレスとポートでサーバに接続
  client = new Client(this, serverAdder, port);
  
  c_keyCodeR = 0;
  c_keyCodeL = 0;
  c_keyCodeU = 0;
  c_keyCodeD = 0;
  
  keyBoolR = false;
  keyBoolL = false;
  keyBoolU = false;
  keyBoolD = false;
  
  scene = 1;
  
  size(1000, 600);
  
  colorMode(HSB, 100);
  ellipseMode(RADIUS);  
}

void draw() {
  if(scene == 0) {
    init();
  } else if (scene == 1) {
    game();
  } else if (scene == 2) {
    clear();
  }
}

void game() {
  
  background(0,0,90);
  show_s();
  show_c();
      
  
}//game()

void init() {
}

void clear() {
}

void keyPressed() {
  if(key == RIGHT) c_keyCodeR = RIGHT; keyBoolR = true;
  if(key == LEFT) c_keyCodeL = LEFT; keyBoolL = true;
  if(key == UP) c_keyCodeU = UP; keyBoolU = true;
  if(key == DOWN) c_keyCodeD = DOWN; keyBoolD = true;
  String msg = 
    c_keyCodeR + " " + keyBoolR + " " +
    c_keyCodeL + " " + keyBoolL + " " +
    c_keyCodeU + " " + keyBoolU + " " +
    c_keyCodeD + " " + keyBoolD + " " +
    "\n";
    client.write(msg);
  
}


void keyReleased() {
  if(key == RIGHT) c_keyCodeR = RIGHT; keyBoolR = false;
  if(key == LEFT) c_keyCodeR = LEFT; keyBoolL = false;
  if(key == UP) c_keyCodeR = UP; keyBoolU = false;
  if(key == DOWN) c_keyCodeR = DOWN; keyBoolD = false;
  
  String msg = 
    c_keyCodeR + " " + keyBoolR + " " +
    c_keyCodeL + " " + keyBoolL + " " +
    c_keyCodeU + " " + keyBoolU + " " +
    c_keyCodeD + " " + keyBoolD + " " +
    "\n";
    client.write(msg);
}

void clientEvent(Client c) {
  //サーバからのデータ取得
  String msg = c.readStringUntil('\n');
  //メッセージが存在する場合
  if (msg != null) {
    //改行を取り除き，空白で分割して配列に格納
    String[] data = splitTokens(msg);
    spx = float(data[0]); 
    spy = float(data[1]);
    spr = float(data[2]);
    spa = float(data[3]);
    spd = boolean(data[4]);
    sph = int(data[5]);
    sphm = int(data[6]);
    cpx = float(data[7]);
    cpy = float(data[8]); 
    cpr = float(data[9]);
    cpa = float(data[10]);
    cpd = boolean(data[11]);
    cph = int(data[12]);
    cphm = int(data[13]);
    scene = int(data[14]);
  }
}
