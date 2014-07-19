
int maxCircles = 10000;
ArrayList<Clan> clanRegister;

float lifeAverageRadius, minLifeRadius;
float weightShiftRate = .3;
void setup() {
 size(800, 800);
 smooth();
 stroke(0);
 stroke(1.5);
 
 lifeAverageRadius = width/100;
 
 minLifeRadius = lifeAverageRadius * .3;
  
 clanRegister = new ArrayList<Clan>();
 
 frameRate(5);
}

void draw() {
  background(255,255,255);
  ArrayList<Clan> livingClans = new ArrayList<Clan>();
  for(int i = 0; i < clanRegister.size(); i++){
    clanRegister.get(i).drawChildren();
    
    if(clanRegister.get(i).lucy.alive) {
      clanRegister.get(i).lucy.liveLife();
      livingClans.add(clanRegister.get(i));
    }
  }
  
  clanRegister = livingClans;
}


void mouseClicked() {
  Clan aNewClan;

  float newRadius = random(lifeAverageRadius - (lifeAverageRadius * weightShiftRate), lifeAverageRadius + (lifeAverageRadius * weightShiftRate));

  if(canDrawLifeAtLocation((float)mouseX, (float)mouseY, newRadius)){
  
      aNewClan = new Clan((float)mouseX, (float)mouseY, newRadius);
      clanRegister.add(aNewClan);
  }  
}

/*
*  HELPER METHODS
*/

boolean canDrawLifeAtLocation(float xNew, float yNew, float rNew) {
  float d;
  
  //check bounds
  //north bound
  if( (yNew - rNew) < 0) {
    println("failed at north bound");
    return false;
  }
  else if((yNew + rNew) > height){
    println("failed at south bound");
    return false;
  }
  else if((xNew - rNew) < 0) {
    println("failed at west bound");
    return false;
  }
  else if((xNew + rNew) > width){
    println("failed at east bound");
    return false;
  }
  
  
  for(int i = 0; i < clanRegister.size(); i++) {
    
    if(steppingOnAnotherLife(clanRegister.get(i).lucy, xNew, yNew, rNew)){
      return false;
    }
    
  }
  
  return true;
  
}

boolean steppingOnAnotherLife(Life parentLife, float xNew, float yNew, float rNew){

  float d = dist(parentLife.x, parentLife.y, xNew, yNew);
  if(d < rNew + parentLife.r){
    return true;
  }
  else {
    for(int i = 0; i < parentLife.children.size(); i++){
    
      return steppingOnAnotherLife(parentLife.children.get(i), xNew, yNew, rNew);
    
    }
    return false;
  }
  
}

/*
* CLAN CLASS
*/

class Clan {

  Life lucy;
  boolean alive = true;
  
  public Clan(float myX, float myY, float myR){
    println("LUCY BORN");
    lucy = new Life(null, myX, myY, myR);
  }
  
  public void drawChildren() {
    lucy.drawBody();
  }
  
}

/*
* LIFE CLASS
*/

class Life {
  
  Life parent;
  ArrayList<Life> children;
  float x, y, r;
  boolean alive = true;
  
 public Life(Life myParent, float myX, float myY, float myR) {
   parent = myParent;
   x = myX;
   y = myY;
   r = myR;
   
   if(parent == null){}
   
   children = new ArrayList<Life>();
   
 }
 
 public void liveLife(){
   if(alive){
     if(children.size() == 0){
       spawn();
     }
     else {
       for(int i = 0; i < children.size(); i++){
         children.get(i).liveLife();
       }
     }
   }
   
 }
 
 public boolean spawn(){
   
   if(alive == false){
     return false;
   }
   println("SPAWN");
   //create new Life as a child of this one
   //if you can't spawn, you can't live, and so this Life will end
   
   //if a suitable place is available for a Life to live
   //create it and return true
   
   
   
   //check all angles around the current life
   //degrees 0-360
   //with a random starting point
   float randomStartingDegree = (float)(int)random(0,359);
   println("randomStartingDegree : " + randomStartingDegree);
   //and a random newRadius
   float newR = random(r - (r * weightShiftRate), r + (r * weightShiftRate)); 
   
   //now see if all this can fit next to the parent node
   boolean canFit = false;
   float angle, newX, newY;
   
   newX = 0;
   newY = 0;
   
   //distance from node is 
   
   
   for(int i = 0; i < 360; i++){
       angle = (randomStartingDegree + i) % 360;
       
       newX = x + cos(angle)*(newR + r);
       newY = y + sin(angle)*(newR + r);
       
       if(canDrawLifeAtLocation(newX, newY, newR)) {
         canFit = true;
         break;
       }
       
       randomStartingDegree++;
   }
   
   println("Can fit after first attempt: " + canFit);
   
   if(canFit == false){
     //if it still can't fit based off of the weight shifted radius, try its smallest possible radius
     //newRadius = myR - (myR * weightShiftRate);
     newR = minLifeRadius;
     for(int i = 0; i < 360; i++){
       angle = (randomStartingDegree + i) % 360;
       
       newX = x + cos(angle)*(newR + r);
       newY = y + sin(angle)*(newR + r);
       
       if(canDrawLifeAtLocation(newX, newY, newR)) {
         canFit = true;
         break;
       }
       
       randomStartingDegree++;
   }
   }
   
   //STILL false.  You're not gonna make it dude
   if(canFit == false) {
     kill();
     return false;
   }
   
   //push this child into children array
   println("new kid: x = " + newX + ", y = "+ newY + ", r = " +  newR);
   Life aNewLife = new Life(this, newX, newY, newR);
   children.add(aNewLife);
   
   return true;

 }
 
 public void drawBody(){
   //TODO health colors;
   
   if(alive){
     noFill();
   }
   else {
     fill(0); 
   }
   
   for(int i = 0; i < children.size(); i++){
     children.get(i).drawBody();
   }
   
   ellipse(x, y, r*2, r*2);
 }
 
// public boolean checkOnTheKids(){
//   //check and see if any child Life objects are still alive;
//   //if so, yay!
//   
//   //if not all, maybe draw me as a little more unhealthy than before
//   
//   
//   
//   //if none, I'm dead.  rough.
//   alive = false;
//   kill();
// }
 
 public void kill(){
   //sometimes life is cruel
   alive = false;
 }
  
}
