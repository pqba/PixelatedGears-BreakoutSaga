PImage bg;
PImage ballOverlay;
PImage paddleOverlay;
PFont customFont;
final int PADDLE_WIDTH = 150;
final int PADDLE_HEIGHT = 40;
final int BALL_DIAMETER = 30;
final int NUM_ROWS = 6; // Adjust as needed
int NUM_COLS; // Calculate based on screen width
final int BRICK_WIDTH = 10;
final float BRICK_WIDTH_RATIO = 0.12; // Adjust as needed
final float BRICK_HEIGHT_RATIO = 0.025; // Adjust as needed
PImage gray_bg;
Paddle paddle;
Ball ball;
Brick[][] bricks;
boolean gameStarted = false;

void setup() {
  fullScreen();
  bg = loadImage("background.jpg");
  bg.resize(displayWidth, displayHeight);
  gray_bg = loadImage("grayscaledbackground.png");
  gray_bg.resize(displayWidth, displayHeight);
  ballOverlay = loadImage("cog.jpeg");
  ballOverlay.resize(BALL_DIAMETER, BALL_DIAMETER);
  paddleOverlay = loadImage("barrel.jpeg");
  paddleOverlay.resize(PADDLE_WIDTH,PADDLE_HEIGHT);

  NUM_COLS = int(displayWidth * BRICK_WIDTH_RATIO) / BRICK_WIDTH;
  float brickWidth = displayWidth / NUM_COLS;
  float brickHeight = displayHeight * BRICK_HEIGHT_RATIO;

  paddle = new Paddle(PADDLE_WIDTH, PADDLE_HEIGHT);
  ball = new Ball(BALL_DIAMETER);
  frameRate(60);

  bricks = new Brick[NUM_ROWS][NUM_COLS];

  for (int i = 0; i < NUM_ROWS; i++) {
    for (int j = 0; j < NUM_COLS; j++) {
      float brickX = j * brickWidth;
      float brickY = i * brickHeight + 50;
      bricks[i][j] = new Brick(brickX, brickY, brickWidth, brickHeight);
    }
  }

  customFont = createFont("ARCADECLASSIC.ttf", 32);
}

// Rest of the code remains the same
void draw() {
  background(gray_bg);
  if (!gameStarted) {
    fill(0);  // Set the fill color to white
    textSize(65);  // Set the text size
    textAlign(CENTER, CENTER);  // Center the text
    textFont(customFont);
    text("Tap   to   Start", width / 2, height / 2);  // Display "Tap to Start" message
    textSize(80);
    text("Pixelated    Gears", width/2, height/2 - height/6);
    textSize(70);
    text("The  Breakout  Saga", width/2, height/2 - height/7);
  } else {
    background(bg);
    checkGameStatus();

    paddle.update();
    image(paddleOverlay, paddle.x,paddle.y); 

    ball.update();
    image(ballOverlay, ball.x - ball.diameter / 2, ball.y - ball.diameter / 2);
    ball.checkPaddleCollision();

    for (int i = 0; i < NUM_ROWS; i++) {
      for (int j = 0; j < NUM_COLS; j++) {
        Brick brick = bricks[i][j];
        brick.display();
        if (ball.checkBrickCollision(brick)) {
          brick.destroy();
          // Calculate speed adjustment based on brick's position
          float relativePosition = (float(i) / NUM_ROWS) * 2 - 1; // Range from -1 to 1
          ball.speedAdjustment = 1.0 + 0.2 * relativePosition; // Adjust the multiplier as needed
          // Apply the adjustment to ball's ySpeed
          ball.ySpeed *= ball.speedAdjustment;
        }
      }
    }
  }
}

void keyPressed() {
  if (keyCode == LEFT) {
    paddle.moveLeft();
  } else if (keyCode == RIGHT) {
    paddle.moveRight();
  }
}

void keyReleased() {
  paddle.stop();
}
void mousePressed() {
  if (!gameStarted) {
    gameStarted = true;  // Start the game
  }
}
void mouseDragged() {
  if (gameStarted) {
    float newX = mouseX - paddle.width / 2;
    // Limit the paddle's position within the screen boundaries
    newX = constrain(newX, 0, displayWidth - paddle.width);
    paddle.x = newX;
  }
}



void checkGameStatus() {
  // Game over condition
  if (ball.isOffScreen()) {
    // Reset the ball and
    ball.reset();
    paddle.reset();
    gameStarted = false;
  }

  // Win condition
  boolean bricksLeft = false;
  for (int i = 0; i < NUM_ROWS; i++) {
    for (int j = 0; j < NUM_COLS; j++) {
      if (!bricks[i][j].isDestroyed()) {
        bricksLeft = true;
        break;
      }
    }
  }

  if (!bricksLeft) {
    // You win!
    background(gray_bg);
    noLoop();
  }
}

class Paddle {
  float x;
  float y;
  float width;
  float height;
  float speed = 5;
  boolean movingLeft = false;
  boolean movingRight = false;

  Paddle(float width, float height) {
    this.width = width;
    this.height = height;
    x = displayWidth / 2;
    y = displayHeight - height;
  }

  void setMovingLeft(boolean moving) {
    movingLeft = moving;
  }

  void setMovingRight(boolean moving) {
    movingRight = moving;
  }

  void update() {
    if (movingLeft && x > 0) {
      x -= speed;
    } else if (movingRight && x < displayWidth - width) {
      x += speed;
    }
  }

  void display() {
    fill(173, 187, 240);
    if (ball.isOffScreen()) {
      fill(255);
      rect(x, y, width, height, 15);
    } else {
      rect(x, y, width, height, 5);
    }
  }

  void reset() {
    x = displayWidth / 2;
  }

  void moveLeft() {
    movingLeft = true;
    movingRight = false;
  }

  void moveRight() {
    movingRight = true;
    movingLeft = false;
  }

  void stop() {
    movingLeft = false;
    movingRight = false;
  }
}




class Ball {
  float x;
  float y;
  float diameter;
  float xSpeed = 5;
  float ySpeed = -5;
  float speedAdjustment = 1.0;

  Ball(float diameter) {
    this.diameter = diameter;
    x = displayWidth / 2 + random(10);
    y = displayHeight / 2 + random(10);
  }

  void update() {
    if (gameStarted) {
      x += xSpeed;
      y += ySpeed;

      if (x < 0 || x > displayWidth) {
        xSpeed *= -1;
      }
      if (y < 0) {
        ySpeed *= -1;
      }
    } else {
      x = paddle.x + paddle.width / 2;
    }
  }

  void display() {
    fill(15, 105, 235);
    ellipse(x, y, diameter, diameter);
  }

  void checkPaddleCollision() {
    if (y + diameter / 2 >= paddle.y && y - diameter / 2 <= paddle.y + paddle.height && x >= paddle.x && x <= paddle.x + paddle.width) {
      ySpeed *= -1;
    }
  }

  boolean checkBrickCollision(Brick brick) {
    if (!brick.isDestroyed() && y - diameter / 2 <= brick.y + brick.height && y + diameter / 2 >= brick.y && x >= brick.x && x <= brick.x + brick.width) {
      ySpeed *= -1;
      return true;
    }
    return false;
  }

  boolean isOffScreen() {
    return y > displayHeight;
  }

  void reset() {
    x = displayWidth / 2;
    y = displayHeight / 2;
  }
  void move() {
    x += xSpeed;
    y += ySpeed;
  }
}


class Brick {
  float x;
  float y;
  float width;
  float height;
  boolean destroyed = false;

  Brick(float x, float y, float width, float height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  void display() {
    if (!destroyed) {
      fill(x, y, 150);
      rect(x, y, width, height);
    }
  }

  void destroy() {
    destroyed = true;
  }

  boolean isDestroyed() {
    return destroyed;
  }
}
