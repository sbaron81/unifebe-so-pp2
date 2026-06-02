import psutil

def get_system_stats():
    return {
        "cpu": {
            "percent": psutil.cpu_percent(interval=None),
            "count": psutil.cpu_count(),
            "freq": psutil.cpu_freq().current if psutil.cpu_freq() else 0
        },
        "memory": {
            "total": psutil.virtual_memory().total,
            "available": psutil.virtual_memory().available,
            "percent": psutil.virtual_memory().percent,
            "swap_total": psutil.swap_memory().total,
            "swap_percent": psutil.swap_memory().percent
        },
        "disk": {
            "partitions": [
                {
                    "device": p.device,
                    "mountpoint": p.mountpoint,
                    "fstype": p.fstype,
                    "percent": psutil.disk_usage(p.mountpoint).percent
                } for p in psutil.disk_partitions() if 'loop' not in p.device
            ]
        }
    }
