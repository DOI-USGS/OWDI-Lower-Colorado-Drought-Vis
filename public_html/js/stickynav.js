var controller = new ScrollMagic.Controller();
		
//Number 1
new ScrollMagic.Scene({
	triggerElement: '#Introduction',
	})
	.setClassToggle('#welcomeLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 2		
new ScrollMagic.Scene({
	triggerElement: '#Lifeline',
	})
	.triggerHook(0)
	.setClassToggle('#welcomeLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
			
new ScrollMagic.Scene({
	triggerElement: '#Lifeline',
	})
	.triggerHook(0)
	.setClassToggle('#lifelineLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	

// Number 3		
new ScrollMagic.Scene({
	triggerElement: '#OneRiver',
	})
	.triggerHook(0)
	.setClassToggle('#oneRiverLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	

new ScrollMagic.Scene({
	triggerElement: '#OneRiver',
	})
	.triggerHook(0)
	.setClassToggle('#lifelineLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller

//Number 4	
new ScrollMagic.Scene({
	triggerElement: '#ControlStructures',
	})
	.triggerHook(0)
	.setClassToggle('#controlLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
	
new ScrollMagic.Scene({
	triggerElement: '#ControlStructures',
	})
	.triggerHook(0)
	.setClassToggle('#oneRiverLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller

//Number 5	
new ScrollMagic.Scene({
	triggerElement: '#WaterSupply',
	})
	.triggerHook(.05)
	.setClassToggle('#controlLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#WaterSupply',
	})
	.triggerHook(.05)
	.setClassToggle('#waterSupplyLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 6	
new ScrollMagic.Scene({
	triggerElement: '#ExtendedDrought',
	})
	.triggerHook(.05)
	.setClassToggle('#waterSupplyLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#ExtendedDrought',
	})
	.triggerHook(.05)
	.setClassToggle('#extendedDroughtLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 7	
new ScrollMagic.Scene({
	triggerElement: '#StorageCapacity',
	})
	.triggerHook(.05)
	.setClassToggle('#extendedDroughtLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#StorageCapacity',
	})
	.triggerHook(.05)
	.setClassToggle('#storageCapacityLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 8
new ScrollMagic.Scene({
	triggerElement: '#SupplyDemand',
	})
	.triggerHook(.05)
	.setClassToggle('#storageCapacityLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#SupplyDemand',
	})
	.triggerHook(.05)
	.setClassToggle('#supplyDemandLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 9
new ScrollMagic.Scene({
	triggerElement: '#DecliningStorage',
	})
	.triggerHook(.05)
	.setClassToggle('#supplyDemandLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#DecliningStorage',
	})
	.triggerHook(.05)
	.setClassToggle('#decliningStorageLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 10
new ScrollMagic.Scene({
	triggerElement: '#Shortage',
	})
	.triggerHook(.05)
	.setClassToggle('#decliningStorageLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#Shortage',
	})
	.triggerHook(.05)
	.setClassToggle('#shortageLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 11
new ScrollMagic.Scene({
	triggerElement: '#EraOfHope',
	})
	.triggerHook(.05)
	.setClassToggle('#shortageLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#EraOfHope',
	})
	.triggerHook(.05)
	.setClassToggle('#eraLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
	
new ScrollMagic.Scene({
	triggerElement: '#stickynavContainer',
	})
	.triggerHook(0)
	.setPin('#stickynavContainer')
	.addTo(controller); // Add Scene to ScrollMagic Controller



