//ソケット通信のためのライブラリを読み込み
import processing.net.*;
Server server;

//プレイヤー2の情報(クライアント)
float c_mouseX, c_mouseY;

//クライアント側の入力
int c_keyCode;
boolean keyBool;

//ポート番号を指定
int port = 20000;

//ゲームの状態遷移(0=タイトル, 1=ゲーム, 2=クリア)
int scene;

//玉の格納
ArrayList<Ball> ball;

//ボールの状態をクライアントに送る用(消されたときのArrayの添字を持つ
String msg_ball = ""; 


//Ballクラス
class Ball {
  //玉の消滅処理
  boolean delete = false;
  float x,y,r,speed;
  //pattern == 0 サーバ, pattern == 1 クライアント)  
  int pattern;
  Ball(float x, float y, float r, float speed, int pattern) {
    this.x = x;
    this.y = y;
    this.r = radians(r);
    this.speed = speed;
    this.pattern = pattern;
  }
  
  void move() {
    x += cos(r)*speed;
    y += sin(r)*speed;
    //サーバであれば
    if (pattern == 0) {
      stroke(50,70,30);
      strokeWeight(4);
      fill(50, 50, 50);
    } else {
      stroke(20,0,0);
      strokeWeight(4);
      fill(20, 0, 0);
    }
    ellipse(x, y, 5, 5);
    
    //サーバであれば
    if(pattern == 0) {
      if(dist(c_player.x, c_player.y, x, y) < c_player.r + 5) {
        c_player.hp -= 1;
        delete = true;
      }
    } else {
      if(dist(s_player.x, s_player.y, x, y) < s_player.r + 5) {
        s_player.hp -= 1;
        delete = true;
      }
    }
  }
}

//KeyStateクラス
class KeyState {
  HashMap<Integer, Boolean> states = new HashMap<Integer, Boolean>();
  KeyState() {}
  
  void initialize() {
    states.put(LEFT, false);
    states.put(RIGHT, false);
    states.put(UP, false);
    states.put(DOWN, false);
  }
  
  boolean get(int code) {
    return states.get(code);
  }
  
  void put(int code, boolean state) {
    states.put(code, state);
  }
}//KeyState class


//Playerクラス

class Player {
  float x,y,r,ang;
  boolean delete = true;
  int hp = 10;
  int hpMax = 10;
  
  Player(float x, float y, float r, float ang) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.ang = ang;
  }
  
  void show_s() {
    if(delete) {
      if(hp < 1) {
        delete = false;
      }
      //サーバプレイヤーの外枠
      stroke(50, 50, 50);
      strokeWeight(4);
      fill(100);
      ellipse(x, y, r, r);

      //HPバー
      translate(x, y);
      stroke(10);
      strokeWeight(2);
      //全体バー
      fill(10,30,30);
      rect(-30,-60,60,13); 
      //減算バー
      fill(30,50,90);
      rect(-30,-60,60*(float(hp)/float(hpMax)),13); 
      translate(-x, -y);
  
      //照準の回転(サーバ)
      ang = atan2(mouseY - y, mouseX - x);
      //始点
      translate(x, y);
      rotate(ang);
      stroke(50, 50, 50);
      strokeWeight(7);
      line(r, 0, r+15, 0);
      
      rotate(-ang);
      translate(-x, -y);
    }

  

  }
  
  void show_c() {
    if(delete) {
      if(hp < 1) {
        delete = false;
      }
      //クライアントプレイヤーの外枠
      stroke(0, 80, 50);
      strokeWeight(4);
      fill(100);
      ellipse(x, y, r, r);

      //HPバー
      translate(x, y);
      stroke(10);
      strokeWeight(2);
      //全体バー
      fill(10,30,30);
      rect(-30,-60,60,13); 
      //減算バー
      fill(30,50,90);
      rect(-30,-60,60*(float(hp)/float(hpMax)),13); 
      translate(-x, -y);
  
        
      //照準の回転(クライアント)
      ang = atan2(c_mouseY - y, c_mouseX - x);
      //始点
      translate(x, y);
      rotate(ang);
      stroke(0, 80, 50);
      strokeWeight(7);
      line(r, 0, r+15, 0);
      rotate(-ang);
      translate(-x, -y);
    }

  }
  
  void hitWall() {
    //端判定(サーバ)
    if(x < r) {
      x = r;
    }
    if(x > width-r) {
      x = width - r;
    }
  
    if(y < r) {
      y = r;
    }
  
    if(y > height-r) {
      y = height - r;
    }
  }
  
}

//サーバ側のキー入力
KeyState s_key_state;
//クライアント側のキー入力
KeyState c_key_state;

//サーバ側のプレイヤー
Player s_player;
//クライアント側のプレイヤー
Player c_player;

void setup() {
  
  c_keyCode = 0;
  keyBool = false;
  
  scene = 1;
  
  
  //サーバを生成port番ポートで立ち上げ
  server = new Server(this, port);
  size(1000, 600);
  
  colorMode(HSB, 100);
  ellipseMode(RADIUS);
  
  //プレイヤーインスタンス
  s_player = new Player(width*0.2, height*0.5, 15, 0);
  c_player = new Player(width*0.8, height*0.5, 15, 0);
  
  //キー入力のインスタンス
  s_key_state = new KeyState();
  s_key_state.initialize();
  c_key_state = new KeyState();
  c_key_state.initialize();
  //発射する玉をアレイリストでインスタンス
  ball = new ArrayList<Ball>();
  
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
  
  s_player.hitWall();
  c_player.hitWall();
  
  
  s_player.show_s();
  c_player.show_c();
  
  //キー操作で，サーバのそれぞれのstateのbooleanをとってくる
  if(s_key_state.get(LEFT)) {
    s_player.x -= 4;
  }
  if(s_key_state.get(RIGHT)) {
    s_player.x += 4;
  }
  if(s_key_state.get(UP)) {
    s_player.y -= 4;
  }
  if(s_key_state.get(DOWN)) {
    s_player.y += 4;
  } 
  
  
  
  //クライアントのキー状況を反映
  c_key_state.put(c_keyCode, keyBool);
  
  //キー操作で，クライアントのそれぞれのstateのbooleanをとってくる
  if(c_key_state.get(LEFT)) {
    c_player.x -= 4;
  }
  if(c_key_state.get(RIGHT)) {
    c_player.x += 4;
  }
  if(c_key_state.get(UP)) {
    c_player.y -= 4;
  }
  if(c_key_state.get(DOWN)) {
    c_player.y += 4;
  }  
  
  
  
  //消される予定の玉を全て事前書き出し
  for (int i=0; i < ball.size(); i++) {
    if(ball.get(i).delete) {
      msg_ball = msg_ball + i + " ";
    }
    
  }
  
 
  
  //玉の発射
  for (int i=0; i < ball.size(); i++) {
    ball.get(i).move();
    if(ball.get(i).delete) {
      msg_ball = msg_ball + i + " ";
      ball.remove(i);
    }
    
  }
  sendAllData();
  
  
  
  
}//game()

void init() {
}

void clear() {
}


void keyPressed() {
  if(key == 'd') s_key_state.put(RIGHT, true);
  if(key == 'a') s_key_state.put(LEFT, true);
  if(key == 'w') s_key_state.put(UP, true);
  if(key == 's') s_key_state.put(DOWN, true);
}

void keyReleased() {
  if(key == 'd') s_key_state.put(RIGHT, false); 
  if(key == 'a') s_key_state.put(LEFT, false);
  if(key == 'w') s_key_state.put(UP, false);
  if(key == 's') s_key_state.put(DOWN, false);
}

//マウスをリリース時に玉を発射
void mouseReleased() {
  ball.add(new Ball(s_player.x, s_player.y, degrees(s_player.ang), 5, 0));
}

//現在の状況をすべてのクライアントに送信

void sendAllData(){
  //サーバに送信するメッセージを作成
  //空白で区切り末尾は改行
  String msg_player = 
    s_player.x + " " +
    s_player.y + " " +
    s_player.r + " " +
    s_player.ang + " " +
    s_player.delete + " " +
    s_player.hp + " " +
    s_player.hpMax + " " +
    c_player.x + " " +
    c_player.y + " " +
    c_player.r + " " +
    c_player.ang + " " +
    c_player.delete + " " +
    c_player.hp + " " +
    c_player.hpMax + " ";
  
  String msg = msg_player + msg_ball + scene + " " + '\n';
  print("server: " + msg);
  //サーバが接続しているすべてのクライアントに送信
  //(複数のクライアントが接続している場合は全てのクライアントに送信)
  //server.write(msg);
}
