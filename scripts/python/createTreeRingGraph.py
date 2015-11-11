from xml.etree import ElementTree
from xml.dom import minidom
from xml.etree.ElementTree import Element, SubElement, Comment, parse
import csv
import os
import math

def main(language):
    global lang
    lang = language
    svg = Element('svg')
    svg.set('xmlns', 'http://www.w3.org/2000/svg')
    svg.set('xmlns:xlink', 'http://www.w3.org/1999/xlink')
    svg.set('viewBox', '0 0 600 320')
    svg.set('preserveAspectRatio', 'xMinYMin meet')
    global css
    css = SubElement(svg, 'style')
    css.set('type', 'text/css')
    css.text = ''
    css.text += 'text {font-family: Sans-Serif; pointer-events: none ;}'
    css.text += '.linebox' + ':hover' + ' { opacity : .25 }'
    script = SubElement(SubElement(svg,'body'), 'script')
    scriptdat = ''
    scriptdat += 'window.onload = function() {drawLines();};'
    scriptdat += 'function drawLines() {line1 = document.getElementById("pline1");points1 = line1.getAttribute("points");line1.setAttribute("points", "");pointl1 = points1.split(" ");tpoints1 = [];allpoints1 = "";i21 = 0;for(i11 = 0; i11 < pointl1.length; i11++){allpoints1 += pointl1[i11] + " ";tpoints1[i11] = allpoints1;window.setTimeout(function() {line1.setAttribute("points", tpoints1[i21]); i21++;}, i11*25);} line1.setAttribute("points", tpoints1[i21] + "0,0"); line2 = document.getElementById("pline2");points2 = line2.getAttribute("points");line2.setAttribute("points", "");pointl2 = points2.split(" ");tpoints2 = [];allpoints2 = "";i22 = 0;for(i12 = 0; i12 < pointl2.length; i12++){allpoints2 += pointl2[i12] + " ";tpoints2[i12] = allpoints2;window.setTimeout(function() {line2.setAttribute("points", tpoints2[i22]); i22++;}, i12*25);}}'
    script.append(Comment(' --><![CDATA[' + scriptdat.replace(']]>', ']]]]><![CDATA[>') + ']]><!-- '))
    main = SubElement(svg, 'g')
    graph = SubElement(main, 'g')
    graph.set('transform', 'translate(65 10)')
    renderGraph(graph, getScriptLoc() + '/../../src_data/treeringFlow10yrProcessed.csv')
    renderLabels(main)
    if lang:
        outsvg = open(getScriptLoc() + '/../../public_html/en/img/droughtMovingAverage.svg','w+')
    else:
        outsvg = open(getScriptLoc() + '/../../public_html/es/img/droughtMovingAverage.svg','w+')
    outsvg.truncate()
    outsvg.write(fixIndentation(svg))
    outsvg.close()
    
def fixIndentation(elem):
    rough_string = ElementTree.tostring(elem)
    reparsed = minidom.parseString(rough_string)
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
    
def drawGraphLine(ele, year1, perc1, yrange, prange, ymin, pmin):
    year1 = (year1 - ymin) * (500/yrange)
    pc = (prange/2) + pmin
    perc1 = (pc - perc1) + pc
    perc1 = (perc1 - pmin) * (250/prange)
    return str(year1) + ',' + str(perc1) + ' '
    
def getScriptLoc():
    return os.getcwd().replace('\\','/')

def renderGraph(ele, floc):
    with open(floc, 'rb') as csvfile:
        doc = csv.reader(csvfile, delimiter=',', quotechar='|')
        i = 0
        x = 0
        year = []
        perc = []
        raw = []
        year2 = []
        for row in doc:
            if(i != 0 and row[1] != 'NA'):
                year.append(row[0])
                perc.append(row[1])
                x+= 1
            if(i != 0):    
                raw.append(row[2])
                year2.append(row[0])
            i+= 1
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
        minside = 0
        maxside = math.ceil(float(max)/5) * 5
        botstep = 500 / ((maxbot - minbot)/10)
        sidestep = 250 / ((maxside - minside)/5)
        drawHighlightBox(ele, 1906, 1922, minbot, maxbot - minbot, '#A3FF75', getValue('natFlowPreCompactTextLine1'), getValue('natFlowPreCompactTextLine2'))
        drawHighlightBox(ele, 2000, 2016, minbot, maxbot - minbot, '#CCCCB2', getValue('natFlowCurrentDroughtTextLine1'), getValue('natFlowCurrentDroughtTextLine2'))
        linecontainer2 = SubElement(ele, 'g')
        linecontainer2.set('stroke', '#9999FF')
        linecontainer2.set('stroke-width', '2')
        linecontainer2.set('fill', 'none')
        linecontainer1 = SubElement(ele, 'g')
        linecontainer1.set('stroke', 'blue')
        linecontainer1.set('stroke-width', '2')
        linecontainer1.set('fill', 'none')
        gline1 = ''
        gline2 = ''
        for i in range(0, len(year)):
            gline1 += drawGraphLine(linecontainer1, float(year[i]), float(perc[i]), maxbot - minbot, maxside - minside, minbot, minside)
        pline = SubElement(linecontainer1, 'polyline')
        pline.set('points', gline1)
        pline.set('id', 'pline1')
        for i in range(0, len(year2)):
            gline2 += drawGraphLine(linecontainer2, float(year2[i]), float(raw[i]), maxbot - minbot, maxside - minside, minbot, minside)
        pline = SubElement(linecontainer2, 'polyline')
        pline.set('points', gline2)
        pline.set('id', 'pline2')
        for i in range(0, 9):
            createLineBox(ele, int(year2[i]), int(year2[i])+1, minbot, maxbot - minbot, None, float(raw[i]), int(year2[i]), i)
        for i in range(0, len(year)):
            createLineBox(ele, int(year2[i+10-1]), int(year2[i+10-1])+1, minbot, maxbot - minbot, float(perc[i]), float(raw[i+10-1]), int(year2[i+10-1]), i+10-1)
        for i in range(0, int((maxbot - minbot)/10) + 1):
            if i % 2 == 0:
                drawLine(ele, i * botstep, 250, i * botstep, 245, 2, 'black')
                drawText(ele, (i * botstep) - (len(str(int((i*10)+minbot)))/2)*10, 270, str(int((i*10)+minbot)))
        for i in range(0, int((maxside - minside)/5) + 1):
            drawLine(ele, 0, i * sidestep, 5, i * sidestep, 2, 'black')
            drawText(ele, -5, 250 - (i * sidestep) + 5, str(int((i * 5) + minside))).set('text-anchor', 'end')
            if int((i * 5) + minside) == 100:
                drawLine(ele, 15, 250 - (i * sidestep), 485, 250 - (i * sidestep), 1, 'black')
        drawLine(ele, 0, 250, 500, 250, 2, 'black')
        drawLine(ele, 0, 250, 0, 0, 2, 'black')
        drawLine(ele, 0, 0, 500, 0, 2, 'black')
        drawLine(ele, 500, 0, 500, 250, 2, 'black')

def renderLabels(ele):
    if lang:
        unit = getValue('unitsImperialVolume')
    else:
        unit = getValue('unitsMetricVolume')
    botl =  getValue('natFlowFigXlab')
    sidel = getValue('natFlowFigYlab') + '(' + unit + ')'
    tex = drawText(ele, 25, 10 + 250 - (250 - (8* len(sidel))) / 2, sidel)
    tex.set('transform', 'rotate(-90 25,' + str(10 + 250 - (250 - (8 * len(sidel))) / 2) + ')')
    drawText(ele, (65+250) - (len(botl)*10)/2, 300, botl)
    
def createLineBox(ele, x1, x2, ymin, yrange, avg, raw, year, rot):
    if lang:
        unit = getValue('unitsImperialVolumeAbbr')
    else:
        unit = getValue('unitsMetricVolumeAbbr')
    box = highlightRange(ele, x1, x2, ymin, yrange)
    box.set('class', 'linebox')
    box.set('fill', 'black')
    box.set('opacity', '0')
    box.set('id', 'box' + str(rot))
    box.set('class', 'linebox')
    css.text += '\n#box' + str(rot) + ':hover ~' + ' .num' + str(rot) + ' { opacity : 1 ;}'
    if avg == None:
        value = ''
    else:
        value = str(round(avg, 2))
    text1 = drawText(ele, 15 + 81.666666, 245, getValue('natFlowLegendAverage')+': ' + value + ' ' + unit)
    text1.set('fill', 'blue')
    text1.set('opacity', '0')
    text1.set('font-weight', 'bold')
    text1.set('font-size', '12')
    text1.set('stroke-width', '.5')
    text1.set('class', 'num' + str(rot))
    text2 = drawText(ele, 15 + 81.666666, 215, getValue('natFlowLegendYear') + ': ' + str(year))
    text2.set('fill', 'black')
    text2.set('opacity', '0')
    text2.set('font-weight', 'bold')
    text2.set('font-size', '12')
    text2.set('class', 'num' + str(rot))
    text3 = drawText(ele, 15 + 81.666666, 230, getValue('natFlowLegendVolume')+': ' + str(round(raw, 2))+ ' ' + unit)
    text3.set('fill', '#9999FF')
    text3.set('opacity', '0')
    text3.set('font-weight', 'bold')
    text3.set('font-size', '12')
    text3.set('stroke-width', '.5')
    text3.set('class', 'num' + str(rot))
    
def drawMinLine(ele, percdata, pmin, prange):
    min = float(percdata[0])
    for val in percdata:
        if float(val) < min:
            min = float(val)
    drawLine(ele, 15, 250 - ((min - pmin)*(250/prange)), 485, 250 - ((min - pmin)*(250/prange)), 1, 'red')
    drawText(ele, 15, 250 - ((min - pmin)*(250/prange)) - 5, 'Minimum').set('fill', 'red')
    
def drawHighlightBox(ele, x1, x2, ymin, yrange, color, text1, text2):
    rect = SubElement(ele, 'rect')
    x1 = (x1 - ymin) * (500/yrange)
    x2 = (x2 - ymin) * (500/yrange)
    rect.set('y', str(0))
    rect.set('height', str(250))
    rect.set('width', str(x2 - x1))
    rect.set('x', str(x1))
    rect.set('fill', color)
    t = drawText(ele, str(x1+2), str(10), text1)
    t.set('fill','black')
    t.set('font-size', '8')
    t = drawText(ele, str(x1+2), str(20), text2)
    t.set('fill','black')
    t.set('font-size', '8')

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
    
def getValue(key):
    if lang:
        data = parse(getScriptLoc() + '/../../src_data/full_text.en.xml').getroot()
    else:
        data = parse(getScriptLoc() + '/../../src_data/full_text.es.xml').getroot()
    return data.find(key).text
    
main(True)
#main(False)
