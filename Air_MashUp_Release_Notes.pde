/*****************************************************
 * AIR MASH-UP APPLICATION NOTES
 * created by Julio Terra 
 *
 * Project overview to come soon.
 *
 * Code licensed under creative commons.
 *
 * 
 * NOTES REGARDING WORK IN PROGRESS
 * 
 * Planned Updates
 * - DONE - create a flag that identifies when a hand is added or removed from the sensor
 * - DONE - ignore volume changes greater than a certain threshold when moving volume up or down gradually
 * - create a flag that identifies the current intent of the user (up or down) when a hand changes direction from going up to down, or down to up
 * - NOT NECESSARY - add a second sensor to the sensor array
 *
 * Physical Ideas
 * - NOT NEEDED - consider adding pedals that enable you to tell the sensor whether your gesture is absolute or gradient
 * - add a laser to identify where the sensors are pointed
 * - add an led that turns on when it senses a hand above the sensor (and turns off when it leaves the sensor)
 * - add light that grows brighter along with the volume
 * - add button and light to route channels to an effects processor 
 * - create a scratch sound channel
 * - consider creating a vocoder like effects channel to layer quotes from youtube and the media on top of the other stuff
 * - consider creating a lock for each channel so that I can swing my arms in front of the sensors.
 *
 * Music Ideas
 * - get samples from youtube and other pop culture references for your set
 *
 * BPM Ideas
 * Inputs
 * - proximity sensor
 * - [optional] switch - direct or accept 
 * - [optional] potentiometer - speed of tempo change after accept
 * - [optional] button to accept the bpm
 * Outputs
 * - led that beats to current bpm
 * - led that beats to new tempo
 *
 *
 * NOTES ABOUT GESTURE CODE:
 * - look for gestures that 
 *
 * Gestures: Volume On and Off
 *   - the center variable holds the current center spot of the volume range
 *   - the bandwidth determines how far up or down the readings need to go in order to move the volume up or down
 *   - the ignore range helps reduce noise by ignoring any large sudden jumps in the sensor readings
 *
 ********************************************************/
