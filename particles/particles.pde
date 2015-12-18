ParticleSystem ps;
int numCollisions = 0;
int numParticles = 100;
int particleLifetime = 255;
void setup() {
  size(640,360);
  ps = new ParticleSystem(new PVector(width/2,50));
}

void draw() {
  background(0);
  ps.run();
  if(ps.particles.size() < numParticles) {
       ps.addParticle();
  }
}



// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;

  ParticleSystem(PVector location) {
    origin = location.get();
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    particles.add(new Particle (new PVector(floor(random(0, 600)), floor(random(0, 400)))));
  }
  
  boolean detectCollision(PVector b, PVector c, Particle id) {
  float dx = c.x - b.x;
  float dy = c.y - b.y;
  float distSquared = dx * dx + dy * dy;
  
  if (distSquared < (id.r * id.r)) {
    numCollisions += 1;
    return true;
  }
  else {
    return false;
  }
}

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      for (int j = i - 1 ; j >= 0; j--) {
        Particle c = (Particle) particles.get(j);
        if(detectCollision(p.getPosition(), c.getPosition(), c)) {
          p.didCollide(c);  
        }
      }
      
      if ((p.isDead()) || (p.location.y > 360)) {
        particles.remove(i);
          if(ps.particles.size() < numParticles) {
             ps.addParticle();
          }
      }
    }
  }
}



// A simple Particle class

class Particle {
  float mass;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  boolean collided;
  float r;
  float m;
  
  Particle(PVector l) {
    m = random(1, 100);
    acceleration = new PVector(0,0.05);
    velocity = new PVector(random(-1,1),random(-2,0));
    location = l.get();
    lifespan = particleLifetime;
    r = random(4, 16);
  }
  
  PVector getPosition() {
   return this.location; 
  }
  
  void didCollide(Particle that) {
    // get distances between the particle's components
    PVector bVect = PVector.sub(that.location, location);

    // calculate magnitude of the vector separating the particles
    float bVectMag = bVect.mag();

    if (bVectMag < r + that.r) {
      // get angle of bVect
      float theta  = bVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated particle's positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
        };

        /* this particle's position is relative to the other
         so you can use the vector between them (bVect) as the 
         reference point in the rotation expressions.
         bTemp[0].position.x and bTemp[0].position.y will initialize
         automatically to 0.0, which is what you want
         since b[1] will rotate around b[0] */
        bTemp[1].x  = cosine * bVect.x + sine * bVect.y;
        bTemp[1].y  = cosine * bVect.y - sine * bVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
        };

      vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
      vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
      vTemp[1].x  = cosine * that.velocity.x + sine * that.velocity.y;
      vTemp[1].y  = cosine * that.velocity.y - sine * that.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
        };

      // final rotated velocity for b[0]
      vFinal[0].x = ((m - that.m) * vTemp[0].x + 2 * that.m * vTemp[1].x) / (m + that.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((that.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + that.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate particle positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate particles
      PVector[] bFinal = { 
        new PVector(), new PVector()
        };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update particles to screen position
      that.location.x = location.x + bFinal[1].x;
      that.location.y = location.y + bFinal[1].y;

      location.add(bFinal[0]);

      // update velocities
      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      that.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      that.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
    }
  }

  void run() {
    update();
    display();
  }

  // Method to update location
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    lifespan -= 1.0;
  }

  // Method to display
  void display() {
    stroke(255,lifespan);
    fill(255,lifespan);
    ellipse(location.x,location.y,(r*2),(r*2));
    text("Number of collisions: " + numCollisions, 10, 10);
  }
  
  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}