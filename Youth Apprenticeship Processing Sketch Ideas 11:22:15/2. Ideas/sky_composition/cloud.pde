/* 
  method for cloud making
*/

void cloud (int cloudNum) {
  // clouds will appear or disappear based on random control
  if ((int) random(0, 2) == 0) {
      fill(skyColor, cloudAlpha);
  } else {
    fill(cloudColor, cloudAlpha);
  }
  noStroke();
  smooth();
  pushMatrix();
  if (cloudTranslate [cloudNum][0] > w) {
    cloudTranslate [cloudNum][0] = 0 - cloudSharpness;
  }
  if (cloudTranslate [cloudNum][1] > h) {
    cloudTranslate [cloudNum][1] = 0 - cloudSharpness;
  }
  translate(
    cloudTranslate [cloudNum][0] += (int) random(-cloudMovement, cloudMovement),
    cloudTranslate [cloudNum][1] += (int) random(-cloudMovement, cloudMovement));
  beginShape();
  for (int i = 0; i < numOfPts; i++) {
    curveVertex(
      random(cloudBase [cloudNum][i][0] - cloudSharpness, cloudBase [cloudNum][i][0] + cloudSharpness),
      random(cloudBase [cloudNum][i][1] - cloudSharpness, cloudBase [cloudNum][i][1] + cloudSharpness));
  }
  endShape();
  popMatrix();
}
