from __future__ import division
import numpy as np
import pandas as pd
from numba import jit
from pandas import Series, DataFrame
from scipy.spatial import distance
import matplotlib.pyplot as plt
import os, random, re, csv
from multiprocessing import Pool

# Basic usage instructions:
# Before running the model you will need to generate resources
# this can be done with starBuilder.py
# You will also need to edit map_name_maker, currently the map locations are hardcoded in that method

#After that you simply need to run main(). Check the bottom of the file for an example. 



def map_reader(file_name, width=1280, height=1024, box_size=16):
    ''' Reads in a map file with the given file location, width, height, and box size
        The map is then returned as a numpy array that represents the map as grid with each location having a resource value'''
    world = pd.read_csv(file_name, delim_whitespace=True, header=None)
    world = np.array(world)
    world_map = np.zeros( (width, height) )
    for item in world:
        world_map[item[0],item[1]] = item[2]
    s_map = np.zeros( (width / box_size, height / box_size) )
    for i in range(s_map.shape[0]):
        for j in range(s_map.shape[1]):
            s_map[i,j] += world_map[i*box_size:(i+1)*box_size,
                                    j*box_size:(j+1)*box_size].sum() #sums all values in each 16x16 square
    return s_map

def map_name_maker(num_stars, clustering, map_num=None):
    '''Generates the file name for a given set up map conditions. Supplying a map_num allows one to pick a
        specific map, otherwise one is randomly chosen with the given resource values
        It is important to note that the location of the maps is currently hard coded and needs to be modified before use '''
    if map_num is None:
        map_num = random.randint(0,999)
    if len(str(num_stars)) < 4:
        num_stars = '0' + str(num_stars)
    if os.name == 'posix':  #location if on osx/linux
        name = os.path.join('/Users/abarr/Sites/simple/maps',
                            '{}stars{}-{}.txt'.format(num_stars, clustering, map_num))
    elif os.name == 'nt': #location if on windows
        name = os.path.join('C:\\Users\\Bryan\\Documents\\simpleForage\\maps',
                            '{}stars{}-{}.txt'.format(num_stars, clustering, map_num))
    return name

def file_name_parser(file_name):
    '''Generates a map name from a file name.
        This function is currently not used '''
    clust = re.search('(clust)([0-9])' ,file_name).groups()[1]
    res = re.search('(res)([0-9]{3,4})' ,file_name).groups()[1]
    map_num = re.search('(map)([0-9]{1,3})', file_name).groups()[1]
    bg = re.search('(wbg|nobg)', file_name).groups()[0]
    return map_reader(map_name_maker(res, clust, map_num))

def tuple_file_name_parser(file_name):
    '''Pulls information from a file name and returns it as a tuple
        This is currently unused '''
    clust = re.search('(clust)([0-9])' ,file_name).groups()[1]
    res = re.search('(res)([0-9]{3,4})' ,file_name).groups()[1]
    map_num = re.search('(map)([0-9]{1,3})', file_name).groups()[1]
    bg = re.search('(wbg|nobg)', file_name).groups()[0]
    return (res, clust, map_num)

@jit('f8(f8,f8,f8,f8)')
def dist( x1,y1,x2,y2 ):
    '''returns the distance between two points'''
    return np.sqrt((x2-x1)**2 + (y2-y1)**2)

def get_value_small(curr_loc, visited):
    '''Returns the value for a given location. 
        This function is used only when very few locations have been explored'''
    val = 0
    for loc in visited:
        val += loc[2] / dist(curr_loc[0], curr_loc[1], loc[0], loc[1]) 
    return val

def get_value(curr_loc, visited):
    '''Calculates the value for a given location given all other visited locations'''
    #take distance between curr_loc and all visited points
    #reduce to 1d vector
    #multiply each dist by its value
    #sum
    if visited.ndim < 2 or len(visited) < 2:
        return get_value_small(curr_loc, visited)
    #cdist a + cidst vprime,currentpoint (maybe divide by 2)
    #val = np.sum(visited[:,2] / ((distance.cdist( visited[:,0:2], [[curr_loc[0], curr_loc[1]]] )[:,0]))) / len(visited) 
    val = np.sum(visited[:,2] / (distance.cdist( visited[:,0:2], [[curr_loc[0], curr_loc[1]]] )[:,0]) )
    #print 'a', val
    #val = val / dist(curr_loc[0], curr_loc[1], visited[-1,0], visited[-1,1])
    #print 'boo yah', len(visited), val
    return val

def get_value_df(row, visited):
    '''A helper function for computing get_value() on a DataFrame'''
    value = get_value((row['x'], row['y']), visited)
    return value

def calc_map_values(unvisited_df, visited):  
    '''Calculates the value at each unvisited location
        Takes a DataFrame of unvisited locations and a numpy array of visited locations'''
    x = unvisited_df.apply(get_value_df, axis=1, args=(visited,))
    unvisited_df['val'] = x
    return unvisited_df
        
def weighted_choice(weights):
    '''Picks a location based on the weighted probalities'''
    totals = np.cumsum(weights)
    norm = totals.iloc[-1]
    r = np.random.rand()
    throw = r*norm
    ind = np.searchsorted(np.array(totals), throw)
    return weights.index[ind]

def get_distance_on_row(row, prev_loc):
    '''Helper function to calculate distances on a DataFrame'''
    return dist(row['x'], row['y'], prev_loc[0], prev_loc[1])
    
def calc_prob_distance(df, gam, beta, prev_loc):
    '''Returns the probability distribution
        Takes a DataFrame containing the world state, gamma, beta, and the newly visited location'''
    if prev_loc is None:
        return np.exp( gam * df['val'].copy() )
    distances = df.apply(get_distance_on_row, axis=1, args=[prev_loc])
    vals = gam * (df['val'].copy() + 1.0) / (beta * distances + 1.0)
    return np.exp( vals )

def get_score_indices(visited_locs, world):
    '''Returns the indices on which resources were located
        This is only used for diagnostic plotting'''
    ind = []
    for i in range(len(visited_locs)):
        if world[visited_locs[i,0], visited_locs[i,1]] > 0:
            ind.append(i)
    return ind

def filter_vals(x, y, world, values, typ):
    '''Ensures that the log is not taken of 0'''
    if world[x,y] == 0:
        val = values[ (values['x'] == x) & (values['y'] == y) ]['val'].iloc[0] 
        if val < 0.00001:
            return -1 * np.log(0.00001)
        return -1 * np.log(val)
    else:
        return world[x,y]

def main(density, clustering, map_num, gamma, beta):
    '''This function will perform one run of the model with the given parameters and write the results to disk
        Note: the out_dir variable hard codes the folder that the results will be output to'''
    out_dir = 'param_search' #modify this to change the output location of the model
    type_spec = 'ln'
    world = map_reader(map_name_maker(density, clustering, map_num))
    visited = [] #should be made up of tuples (x,y,value)
    visited2 = [] #should be made up of tuples (x,y,value)
    output = [] #used to produce an output to visualized later
    data = {'x':[], 'y':[], 'val':[]}
    for i in range(world.shape[0]):
        for j in range(world.shape[1]):
            data['x'].append(i)
            data['y'].append(j)
            data['val'].append(world[i,j])
    df = DataFrame(data)
    
    found_resource = False
    for i in range(300):
        v = np.array(visited)
        df2 = calc_map_values(df.copy(), v)
        
        if i == 0:
            df['val'] = calc_prob_distance(df2.copy(), gamma, beta, None)
        else:
            df['val'] = calc_prob_distance(df2.copy(), gamma, beta, (visited[-1][0], visited[-1][1]))
        
        index = weighted_choice(df['val'])
        
        x = df.ix[index]['x']
        y = df.ix[index]['y']

        visited.append( (x, y, filter_vals(x,y, world, df2, type_spec)) )
        output.append( (x, y, df2[ (df2['x'] == x) & (df2['y'] == y) ]['val'].iloc[0], world[x,y]) )
        df = df.drop(index)
        
    clust = np.array(visited)

    if not os.path.exists(out_dir):
        os.mkdir(out_dir)
    ind = get_score_indices(clust, world)
    fname = os.path.join(out_dir, 'gamma{}-beta{}-clust{}-res{}-map{}'.format(gamma, beta, clustering, density, map_num))
    
    np.savetxt(fname + '.txt', np.array(output))
    
    fig = plt.figure(None, (12,6))
    ax = plt.subplot(1,2,1)
    plt.plot(clust[:,0], clust[:,1], '-o')
    plt.xlim(0,80)
    plt.ylim(0,64)
    ax = plt.subplot(1,2,2)
    plt.plot(clust[ind,0], clust[ind,1], '-o' )
    plt.xlim(0,80)
    plt.ylim(0,64)
    plt.suptitle('clust{}-res{}-lambda {}-{}'.format(clustering, density, gamma, type_spec))
    plt.title('Score: {}'.format(clust[ind,2].sum()))
    plt.savefig(fname+'.png', dpi=200)
    plt.close("all")
    
    return [density, clustering, map_num, gamma, beta]

def callback_func(params):
    print params

    
# The lines in this if statement serves to run the model in bulk. Each run is performed by calling main().
# This example is set up to run across all resource conditions and a variety of a gamma and beta values
# editing the lists will modify what the model does.
if __name__ == '__main__':
    pool = Pool(processes=5)
    densitys = [100, 600, 1100]
    clusterings = [1, 3, 5]
    gammas = [4.5, 5.0, 5.5, 6.0, 6.5]
    betas = [0.075, 0.1, 0.125, 0.15, 0.175]
    for density in densitys:
        for clustering in clusterings:
            for gamma in gammas:
                for beta in betas:
                    for map_num in range(20):
                        pool.apply_async(main, [density, clustering, map_num, gamma, beta], callback=callback_func)
    pool.close()
    pool.join()
    print 'done'
