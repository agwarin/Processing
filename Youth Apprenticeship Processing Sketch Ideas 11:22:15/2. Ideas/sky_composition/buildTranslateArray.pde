/*
  this method is to create random points to use
  for translation of a cloud position
*/

void buildTranslateArray () {
  for (int i = 0; i < numOfClouds; i++) {
    cloudTranslate [i][0] = (int) random(0, w);
    cloudTranslate [i][1] = (int) random(0, h);    
  }
}
