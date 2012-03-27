import re
import ifcb
import os

class OldPid(object):
    def __init__(self,pid):
        self.lid = ifcb.lid(pid)
    def mod(self,regex,what='ID'):
        """match or die"""
        try:
            return re.match(regex,self.lid).groups()[0]
        except:
            raise KeyError('unrecognized %s in IFCB ID: %s' % (what,self.lid))
    @property
    def instrument_number(self):
        return self.mod(r'.*IFCB(\d+).*','instrument number')
    @property
    def instrument_name(self):
        return self.mod(r'.*(IFCB\d+).*','instrument name')
    @property
    def year(self):
        return self.mod(r'^IFCB\d+_(\d{4})','year')
    @property
    def yearday(self):
        return self.mod(r'^IFCB\d+_(\d{4}_\d{3})','year/day')
    @property
    def day(self):
        return self.mod(r'^IFCB\d+_\d{4}_(\d{3})','day')
    @property
    def datetime(self):
        return self.mod(r'^IFCB\d+_(\d{4}_\d{3}_\d{6})','datetime')
    @property
    def target(self):
        return self.mod(r'^IFCB\d+_\d{4}_\d{3}_\d{6}_(\d+)','target')
    @property
    def isday(self):
        return re.match(r'^IFCB\d+_\d{4}_\d{3}$',self.lid)
    @property
    def isbin(self):
        return re.match(r'^IFCB\d+_\d{4}_\d{3}_\d{6}$',self.lid)
    @property
    def istarget(self):
        return re.match(r'^IFCB\d+_\d{4}_\d{3}_\d{6}_\d+$',self.lid)
    @property
    def day_lid(self):
        if self.isday:
            return self.lid
        else:
            return re.sub(r'(^IFCB\d+_\d{4}_\d{3}).*',r'\1',self.lid)
    @property
    def bin_lid(self):
        if self.isbin:
            return self.lid
        else:
            return re.sub(r'(^IFCB\d+_\d{4}_\d{3}_\d{6}).*',r'\1',self.lid)
    @property
    def as_lid(self):
        return self.lid
    @property
    def as_pid(self):
        return ifcb.pid(self.lid)
    def paths(self,basedirs=['.']):
        """Given a bin ID, generate candidate paths, in order of likelihood"""
        (bin, day) = re.match(r'.*((IFCB\d+_\d{4}_\d{3})_\d{6})',self.lid).groups() 
        for basedir in basedirs:
            yield os.path.join(basedir, day, bin)
        # OK, that failed. maybe it's in a previous day
        (instrument, year, doy) = (self.instrument_name, int(self.year), int(self.day))
        if doy < 2 or doy > 364:
            for basedir in basedirs:
                for yesteryear, yesterday in ((year, ((doy - 2) % 365) + 1),
                                              (year-1, ((doy - 2) % 365) + 1),
                                              (year, ((doy - 2) % 366) + 1),
                                              (year-1, ((doy - 2) % 366) + 1)):
                    day = '%s_%d_%03d' % (instrument, yesteryear, yesterday)
                    yield os.path.join(basedir, day, bin)


if __name__=='__main__':
    pid = OldPid('IFCB4_1973_004_231422')
    if pid.isday:
        print 'is day'
    print pid.instrument_name
    print pid.year
    print pid.yearday
    print pid.day
    print pid.datetime
    for path in pid.paths(['foo','bar']):
        print path
    print pid.target



    
