from xml.etree import ElementTree
from xml.dom import minidom
from xml.etree.ElementTree import Element, SubElement, Comment
import csv
import os
import math

def main():
    svg = Element('svg')
    svg.set('xmlns', 'http://www.w3.org/2000/svg')
    svg.set('xmlns:xlink', 'http://www.w3.org/1999/xlink')
    svg.set('viewBox', '0 0 600 320')
    svg.set('preserveAspectRatio', 'xMinYMin meet')
    global css
    css = SubElement(svg, 'style')
    css.set('type', 'text/css')
    css.text = ''
    css.text += 'text {font-family: Sans-Serif}'
    css.text += '.linebox' + ':hover' + ' { opacity : .25 }'
    main = SubElement(svg, 'g')
    graph = SubElement(main, 'g')
    graph.set('transform', 'translate(65 10)')
    renderGraph(graph, getScriptLoc() + '/../../src_data/treeringFlow15yrProcessed.csv')
    renderLabels(main)
    outsvg = open(getScriptLoc() + '/../../public_html/img/droughtMovingAverage.svg','w+')
    outsvg.truncate()
    outsvg.write(prettify(svg))
    outsvg.close()
    
def prettify(elem):
    rough_string = ElementTree.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    #xmlcss = reparsed.createProcessingInstruction('xml-stylesheet', 'type="text/css" href="../css/svg.css"')
    #reparsed.insertBefore(xmlcss, reparsed.firstChild)
    return reparsed.toprettyxml(indent="  ")
    
def drawLine(ele, x1, y1, x2, y2, width = None, color = None):
    line = SubElement(ele, 'line')
    line.set('x1', str(x1))
    line.set('y1', str(y1))
    line.set('x2', str(x2))
    line.set('y2', str(y2))
    if color != None:
        line.set('stroke', color)
    if width != None:
        line.set('stroke-width', str(width))
    return line
    
def drawText(ele, x, y, tex):
    text = SubElement(ele, 'text')
    text.set('x', str(x))
    text.set('y', str(y))
    text.set('fill', 'black')
    text.text=tex
    return text
    
def drawGraphLine(ele, year1, perc1, year2, perc2, yrange, prange, ymin, pmin, itn):
    year1 = (year1 - ymin) * (500/yrange)
    year2 = (year2 - ymin) * (500/yrange)
    pc = (prange/2) + pmin
    perc1 = (pc - perc1) + pc
    perc2 = (pc - perc2) + pc
    perc1 = (perc1 - pmin) * (250/prange)
    perc2 = (perc2 - pmin) * (250/prange)
    gline = drawLine(ele, year1, perc1, year2, perc2)
    animation = SubElement(gline, 'animate')
    animation.set('attributeName', 'visibility')
    animation.set('from', 'hidden')
    animation.set('to', 'visible')
    animation.set('dur', str(itn*.05))
    
def getScriptLoc():
    return os.getcwd().replace('\\','/')

def renderGraph(ele, floc):
    with open(floc, 'rb') as csvfile:
        doc = csv.reader(csvfile, delimiter=',', quotechar='|')
        i = 0
        x = 0
        year = []
        perc = []
        per = []
        raw = []
        year2 = []
        for row in doc:
            if(i != 0 and row[1] != 'NA'):
                year.append(row[0])
                perc.append(row[1])
                per.append(row[4])
                x+= 1
            if(i != 0):    
                raw.append(row[2])
                year2.append(row[0])
            i+= 1
        year = year[-100:]
        perc = perc[-100:]
        per = per[-100:]
        minbot = math.floor(float(year[0])/10) * 10
        if(minbot > 1900):
            minbot = 1900
        maxbot = math.ceil(float(year[len(year)-1])/10) * 10
        min = float(perc[0])
        max = float(perc[0])
        for num in raw:
            if float(num) < min:
                min = float(num)
        for num in raw:
            if float(num) > max:
                max = float(num)
        minside = math.floor(float(min)/5) * 5
        maxside = math.ceil(float(max)/5) * 5
        botstep = 500 / ((maxbot - minbot)/10)
        sidestep = 250 / ((maxside - minside)/5)
        for i in range(0, len(per)-1):
            if float(per[i]) > 10 and float(per[i+1]) == 0:
                highlightRange(ele, int(year[i]) - int(per[i]) + 1, int(year[i]), minbot, maxbot - minbot)
            if float(per[i]) > 10 and i + 1 == len(per)-1:
                highlightRange(ele, int(year[i]) - int(per[i]) + 1, int(year[i+1]), minbot, maxbot - minbot)
        drawGreenBox(ele, 1906, 1922, minbot, maxbot - minbot)
        drawGreenBox(ele, 2000, 2015, minbot, maxbot - minbot)
        for i in range(0, len(year)-1):
            createLineBox(ele, int(year[i]), int(year[i])+1, minbot, maxbot - minbot, float(perc[i]), int(year[i]), i)
        for i in range(0, int((maxbot - minbot)/10) + 1):
            if i % 2 == 0:
                drawLine(ele, i * botstep, 250, i * botstep, 245, 2, 'black')
                drawText(ele, (i * botstep) - (len(str(int((i*10)+minbot)))/2)*10, 270, str(int((i*10)+minbot)))
        linecontainer2 = SubElement(ele, 'g')
        linecontainer2.set('stroke', '#9999FF')
        linecontainer2.set('stroke-width', '2')
        linecontainer1 = SubElement(ele, 'g')
        linecontainer1.set('stroke', 'blue')
        linecontainer1.set('stroke-width', '2')
        for i in range(0, len(year)-1):
            drawGraphLine(linecontainer1, float(year[i]), float(perc[i]), float(year[i+1]), float(perc[i+1]), maxbot - minbot, maxside - minside, minbot, minside, i)
        for i in range(0, len(year2)-1):
            drawGraphLine(linecontainer2, float(year2[i]), float(raw[i]), float(year2[i+1]), float(raw[i+1]), maxbot - minbot, maxside - minside, minbot, minside, i)
        drawMinLine(ele, perc, minside, maxside - minside)
        for i in range(0, int((maxside - minside)/5) + 1):
            drawLine(ele, 0, i * sidestep, 5, i * sidestep, 2, 'black')
            drawText(ele, -30, 250 - (i * sidestep) + 5, str(int((i * 5) + minside)))
            if int((i * 5) + minside) == 100:
                drawLine(ele, 15, 250 - (i * sidestep), 485, 250 - (i * sidestep), 1, 'black')
        drawLine(ele, 0, 250, 500, 250, 2, 'black')
        drawLine(ele, 0, 250, 0, 0, 2, 'black')
        drawLine(ele, 0, 0, 500, 0, 2, 'black')
        drawLine(ele, 500, 0, 500, 250, 2, 'black')

def renderLabels(ele):
    botl =  'Year'
    sidel = 'Averaged Flow Data'
    tex = drawText(ele, 25, 10 + 250 - (250 - (8* len(sidel))) / 2, sidel)
    tex.set('transform', 'rotate(-90 25,' + str(10 + 250 - (250 - (8 * len(sidel))) / 2) + ')')
    drawText(ele, (65+250) - (len(botl)*10)/2, 300, botl)

def highlightRange(ele, x1, x2, ymin, yrange):
    rect = SubElement(ele, 'rect')
    x1 = (x1 - ymin) * (500/yrange)
    x2 = (x2 - ymin) * (500/yrange)
    rect.set('y', str(0))
    rect.set('height', str(250))
    rect.set('width', str(x2 - x1))
    rect.set('x', str(x1))
    rect.set('fill', '#CCCCB2')
    return rect
    
def createLineBox(ele, x1, x2, ymin, yrange, avg, year, rot):
    box = highlightRange(ele, x1, x2, ymin, yrange)
    box.set('class', 'linebox')
    box.set('fill', 'blue')
    box.set('opacity', '0')
    box.set('id', 'box' + str(rot))
    box.set('class', 'linebox')
    css.text += '\n#box' + str(rot) + ':hover ~' + ' .num' + str(rot) + ' { opacity : 1 }'
    text1 = drawText(ele, 15, 245, 'Flow: ' + str(round(avg, 2)))
    text1.set('fill', 'green')
    text1.set('opacity', '0')
    text1.set('font-weight', 'bold')
    text1.set('font-size', '12')
    text1.set('class', 'num' + str(rot))
    text2 = drawText(ele, 15, 15, 'Year: ' + str(year))
    text2.set('fill', 'blue')
    text2.set('opacity', '0')
    text2.set('font-weight', 'bold')
    text2.set('font-size', '12')
    text2.set('class', 'num' + str(rot))
    
def drawMinLine(ele, percdata, pmin, prange):
    min = float(percdata[0])
    for val in percdata:
        if float(val) < min:
            min = float(val)
    drawLine(ele, 15, 250 - ((min - pmin)*(250/prange)), 485, 250 - ((min - pmin)*(250/prange)), 1, 'red')
    drawText(ele, 15, 250 - ((min - pmin)*(250/prange)) - 5, 'Minimum').set('fill', 'red')
    
def drawGreenBox(ele, x1, x2, ymin, yrange):
    rect = SubElement(ele, 'rect')
    x1 = (x1 - ymin) * (500/yrange)
    x2 = (x2 - ymin) * (500/yrange)
    rect.set('y', str(0))
    rect.set('height', str(250))
    rect.set('width', str(x2 - x1))
    rect.set('x', str(x1))
    rect.set('fill', '#A3FF75')
    
main()