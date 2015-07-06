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
    main = SubElement(svg, 'g')
    graph = SubElement(main, 'g')
    graph.set('transform', 'translate(65 35)')
    renderGraph(graph, getScriptLoc() + '/../../src_data/treeringFlow15yrProcessed.csv')
    renderLabels(main)
    outsvg = open(getScriptLoc() + '/../../public_html/img/treering.svg','w+')
    outsvg.truncate()
    outsvg.write(prettify(svg))
    outsvg.close()
    
def prettify(elem):
    rough_string = ElementTree.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ")
    
def drawLine(ele, x1, y1, x2, y2, width, color):
    line = SubElement(ele, 'line')
    line.set('x1', str(x1))
    line.set('y1', str(y1))
    line.set('x2', str(x2))
    line.set('y2', str(y2))
    line.set('stroke', color)
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
    gline = drawLine(ele, year1, perc1, year2, perc2, 2, 'blue')
    animation = SubElement(gline, 'animate')
    animation.set('attributeName', 'visibility')
    animation.set('from', 'hidden')
    animation.set('to', 'visible')
    animation.set('dur', str(itn*.01))
    
def getScriptLoc():
    return os.getcwd().replace('\\','/')

def renderGraph(ele, floc):
    with open(floc, 'rb') as csvfile:
        doc = csv.reader(csvfile, delimiter=',', quotechar='|')
        i = 0
        x = 0
        year = []
        perc = []
        for row in doc:
            if(i != 0 and row[1] != 'NA'):
                year.append(row[0])
                perc.append(row[1])
                x+= 1
            i+= 1
        minbot = math.floor(float(year[0])/100) * 100
        maxbot = math.ceil(float(year[len(year)-1])/100) * 100
        min = float(perc[0])
        max = float(perc[0])
        for num in perc:
            if float(num) < min:
                min = float(num)
        for num in perc:
            if float(num) > max:
                max = float(num)
        minside = math.floor(float(min)/5) * 5
        maxside = math.ceil(float(max)/5) * 5
        botstep = 500 / ((maxbot - minbot)/100)
        sidestep = 250 / ((maxside - minside)/5)
        for i in range(0, int((maxbot - minbot)/100) + 1):
            if i % 2 == 0:
                drawLine(ele, i * botstep, 250, i * botstep, 245, 2, 'black')
                drawText(ele, (i * botstep) - (len(str(int((i*100)+minbot)))/2)*10, 265, str(int((i*100)+minbot)))
        for i in range(0, int((maxside - minside)/5) + 1):
            drawLine(ele, 0, i * sidestep, 5, i * sidestep, 2, 'black')
            drawText(ele, -30, 250 - (i * sidestep) + 5, str(int((i * 5) + minside)))
        for i in range(0, len(year)-1):
            drawGraphLine(ele, float(year[i]), float(perc[i]), float(year[i+1]), float(perc[i+1]), maxbot - minbot, maxside - minside, minbot, minside, i)
        drawLine(ele, 0, 250, 500, 250, 2, 'black')
        drawLine(ele, 0, 250, 0, 0, 2, 'black')

def renderLabels(ele):
    drawText(ele, 250, 20, 'Tree Ring Data')
    tex = drawText(ele, 25, 215, 'Percent of Mean')
    tex.set('transform', 'rotate(-90 25,215)')
    drawText(ele, 280, 325, 'Year')

main()
