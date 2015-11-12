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
	offset:400
	})
	.setClassToggle('#welcomeLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
		
new ScrollMagic.Scene({
	triggerElement: '#Lifeline',
	offset:400
	})
	.setClassToggle('#lifelineLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
// Number 3		
new ScrollMagic.Scene({
	triggerElement: '#OneRiver',
	offset:400
	})
	.setClassToggle('#oneRiverLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	

new ScrollMagic.Scene({
	triggerElement: '#OneRiver',
	offset:400
	})
	.setClassToggle('#lifelineLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller

//Number 4	
new ScrollMagic.Scene({
	triggerElement: '#ControlStructures',
	offset:400
	})
	.setClassToggle('#controlLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
	
new ScrollMagic.Scene({
	triggerElement: '#ControlStructures',
	offset:400
	})
	.setClassToggle('#oneRiverLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller

//Number 5	
new ScrollMagic.Scene({
	triggerElement: '#WaterSupply',
	offset:400
	})
	.setClassToggle('#controlLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#WaterSupply',
	offset:400
	})
	.setClassToggle('#waterSupplyLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 6	
new ScrollMagic.Scene({
	triggerElement: '#ExtendedDrought',
	offset:400
	})
	.setClassToggle('#waterSupplyLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#ExtendedDrought',
	offset:400
	})
	.setClassToggle('#extendedDroughtLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 7	
new ScrollMagic.Scene({
	triggerElement: '#StorageCapacity',
	offset:400
	})
	.setClassToggle('#extendedDroughtLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#StorageCapacity',
	offset:400
	})
	.setClassToggle('#storageCapacityLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 8
new ScrollMagic.Scene({
	triggerElement: '#SupplyDemand',
	offset:400
	})
	.setClassToggle('#storageCapacityLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#SupplyDemand',
	offset:400
	})
	.setClassToggle('#supplyDemandLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 9
new ScrollMagic.Scene({
	triggerElement: '#DecliningStorage',
	offset:400
	})
	.setClassToggle('#supplyDemandLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#DecliningStorage',
	offset:400
	})
	.setClassToggle('#decliningStorageLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 10
new ScrollMagic.Scene({
	triggerElement: '#Shortage',
	offset:400
	})
	.setClassToggle('#decliningStorageLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#Shortage',
	offset:400
	})
	.setClassToggle('#shortageLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
//Number 11
new ScrollMagic.Scene({
	triggerElement: '#EraOfHope',
	offset:400
	})
	.setClassToggle('#shortageLink', 'notCurrent')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	
new ScrollMagic.Scene({
	triggerElement: '#EraOfHope',
	offset:400
	})
	.setClassToggle('#eraLink', 'current')
	.addTo(controller); // Add Scene to ScrollMagic Controller
	