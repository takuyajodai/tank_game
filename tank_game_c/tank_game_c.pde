//ソケット通信のためのライブラリを読み込み
import processing.net.*;
Client client;


//プレイヤー2の情報(クライアント)
float c_mouseX, c_mouseY;



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
ArrayList<Ball> ball_s;
ArrayList<Ball> ball_c;

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
      strokeWeight(3);
      fill(50, 50, 50);
    } else {
      stroke(20,0,0);
      strokeWeight(3);
      fill(80, 50, 80);
    }
    
    ellipse(x, y, 5, 5);
    
    //サーバであれば
    if(pattern == 0) {
      if(dist(cpx, cpy, x, y) < cpr + 5) {
        cph -= 1;
        delete = true;
      }
    } else {
      if(dist(spx, spy, x, y) < spr + 5) {
        sph -= 1;
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
    println("ここまでok");
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

//クライアント側のキー入力
KeyState c_key_state;

void setup() {
  //指定されたアドレスとポートでサーバに接続
  client = new Client(this, serverAdder, port);
  
  scene = 1;
  
  size(1000, 600);
  
  colorMode(HSB, 100);
  ellipseMode(RADIUS);  
  
  c_key_state = new KeyState();
  c_key_state.initialize();
  
  ball_c = new ArrayList<Ball>();
  //ball_s = new ArrayList<Ball>();
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
  
  
  show_c();
  show_s();
      
      
  //キー操作で，クライアントのそれぞれのstateのbooleanをとってくる
  if(c_key_state.get(LEFT)) {
    cpx -= 4;
  }
  if(c_key_state.get(RIGHT)) {
    cpx += 4;
  }
  if(c_key_state.get(UP)) {
    cpy -= 4;
  }
  if(c_key_state.get(DOWN)) {
    cpy += 4;
  }  
  
  String msg = 
    cpx + " " +
    cpy + " " +
    cpa + " " +
    mouseX + " " +
    mouseY + " " +
    sph + " " +
    "\n";
  client.write(msg);
  
  
  //玉の発射(クライアント)
  for (int i=0; i < ball_c.size(); i++) {
    ball_c.get(i).move();
    if(ball_c.get(i).delete) {
      ball_c.remove(i);
    }
  }
  
  /*
  for (int j=0; j < ball_s.size(); j++) {
    ball_s.get(j).move();
    if(ball_s.get(j).delete) {
      ball_s.remove(j);
    } 
  }
  */
  
}//game()

void init() {
}

void clear() {
}

void keyPressed() {
  if(key == 'd') c_key_state.put(RIGHT, true);
  if(key == 'a') c_key_state.put(LEFT, true);
  if(key == 'w') c_key_state.put(UP, true);
  if(key == 's') c_key_state.put(DOWN, true);
}

void keyReleased() {
  if(key == 'd') c_key_state.put(RIGHT, false); 
  if(key == 'a') c_key_state.put(LEFT, false);
  if(key == 'w') c_key_state.put(UP, false);
  if(key == 's') c_key_state.put(DOWN, false);
}

void mouseReleased() {
  ball_c.add(new Ball(cpx, cpy, degrees(cpa), 5, 1));
  //サーバの情報を追加
  //ball_s.add(new Ball(ball_x, ball_y, degrees(spr), 5, 0));
  
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
