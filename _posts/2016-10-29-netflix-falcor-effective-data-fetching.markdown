---
layout: post
title: netflix falcor effective data fetching
date: 2016-10-29 21:58:00 +000
tags: netflix falcor data fetching
---

Gist from [Keynote - JSON Graph: Reactive REST at Netflix](https://www.youtube.com/watch?v=hOE6nVVr14c) and example falcor request/response

motivation
----------
- cache consistency
- loose coupling
- low latency
- small message sizes

approach
--------
- turn JSON tree structure into JSON graph
- remove duplication by using references
- path evaluation

![](http://netflix.github.io/falcor/images/services-diagram.png)
source: http://netflix.github.io/falcor/starter/what-is-falcor.html

example request
-----
```
{
    "paths": [
        ["videos", 70301645, ["maturity", "bookmarkPosition", "runtime", "requestId", "availability", "watched", "regularSynopsis", "queue", "evidence", "episodeCount", "info", "seasonCount", "releaseYear", "userRating", "numSeasonsLabel"]],
        ["videos", 70301645, "trailers", "summary"],
        ["videos", 70301645, "bb2OGLogo", "_400x90", "webp"],
        ["videos", 70301645, "genres", {
                "from": 0,
                "to": 2
            },
            ["id", "name"]
        ],
        ["videos", 70301645, "genres", "summary"],
        ["videos", 70301645, "tags", {
                "from": 0,
                "to": 9
            },
            ["id", "name"]
        ],
        ["videos", 70301645, "tags", "summary"],
        ["videos", 70301645, "cast", {
                "from": 0,
                "to": 5
            },
            ["id", "name"]
        ],
        ["videos", 70301645, "cast", "summary"],
        ["videos", 70301645, "seasonList", "current", "summary"],
        ["videos", 70301645, "current", ["title", "bookmarkPosition", "summary", "synopsis", "runtime", "episodeBadges"]],
        ["videos", 70301645, "current", "ancestor", "summary"],
        ["videos", 70301645, "current", "interestingMoment", "_665x375", "webp"],
        ["videos", 70301645, "artWorkByType", "BILLBOARD", "_1280x720", "webp"],
        ["videos", 70301645, "BGImages", 470, "webp"]
    ],
    "authURL": "1111111111111.XXXXXXXXXXXXXXXXXXXXXXXXXXX="
}
```

example response
-----
```
{
    "value": {
        "$size": 1584,
        "size": 1584,
        "videos": {
            "$size": 1548,
            "size": 1548,
            "70301645": {
                "$size": 1548,
                "size": 1548,
                "availability": {
                    "isPlayable": true,
                    "$type": "leaf",
                    "$size": 29,
                    "size": 29
                },
                "info": {
                    "message": null,
                    "$type": "leaf",
                    "$size": 26,
                    "size": 26
                },
                "requestId": "2e958f1f-0dd5-4ec8-95e3-8280971003b1-6105504",
                "maturity": {
                    "rating": {
                        "value": "12",
                        "maturityDescription": "moderate fantasy action violence, threat, moderate bad language",
                        "maturityLevel": 90,
                        "board": "BBFC",
                        "reasons": []
                    },
                    "$type": "leaf",
                    "$size": 158,
                    "size": 158
                },
                "runtime": 7263,
                "numSeasonsLabel": {
                    "$type": "sentinel",
                    "value": null,
                    "$size": 28,
                    "size": 28
                },
                "queue": {
                    "inQueue": false,
                    "$type": "leaf",
                    "$size": 27,
                    "size": 27
                },
                "seasonCount": {
                    "$type": "sentinel",
                    "value": null,
                    "$size": 28,
                    "size": 28
                },
                "releaseYear": 2014,
                "regularSynopsis": "On the run from intergalactic warlord Ronan, hotshot space pilot Peter Quill unites a ragtag band of oddballs to form a team of unlikely heroes.",
                "watched": false,
                "bookmarkPosition": -1,
                "episodeCount": {
                    "$type": "sentinel",
                    "value": null,
                    "$size": 28,
                    "size": 28
                },
                "userRating": {
                    "average": 4.3591285,
                    "predicted": 4.8,
                    "userRating": null,
                    "type": "star",
                    "$type": "leaf",
                    "$size": 74,
                    "size": 74
                },
                "trailers": {
                    "$size": 22,
                    "size": 22,
                    "summary": {
                        "length": 0,
                        "$type": "leaf",
                        "$size": 22,
                        "size": 22
                    }
                },
                "bb2OGLogo": {
                    "$size": 32,
                    "size": 32,
                    "_400x90": {
                        "$size": 32,
                        "size": 32,
                        "webp": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        }
                    }
                },
                "genres": {
                    "$size": 56,
                    "size": 56,
                    "0": ["genres", "1365"],
                    "1": ["genres", "7442"],
                    "2": {
                        "_sentinel": true,
                        "$type": "sentinel",
                        "$size": 32,
                        "size": 32
                    },
                    "summary": {
                        "length": 2,
                        "$type": "leaf",
                        "$size": 22,
                        "size": 22
                    }
                },
                "evidence": {
                    "type": "hook",
                    "priority": 2,
                    "value": {
                        "kind": "BoxOffice",
                        "text": "Chris Pratt and Bradley Cooper star in this sleeper smash that hit No. 3 at the box office for 2014."
                    },
                    "$type": "leaf",
                    "$size": 166,
                    "size": 166
                },
                "tags": {
                    "$size": 538,
                    "size": 538,
                    "0": {
                        "$size": 2,
                        "size": 2,
                        "name": "Exciting",
                        "id": 100041
                    },
                    "1": {
                        "$size": 2,
                        "size": 2,
                        "name": "Imaginative",
                        "id": 100046
                    },
                    "3": {
                        "$size": 64,
                        "size": 64,
                        "name": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        },
                        "id": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        }
                    },
                    "5": {
                        "$size": 64,
                        "size": 64,
                        "name": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        },
                        "id": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        }
                    },
                    "9": {
                        "$size": 64,
                        "size": 64,
                        "name": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        },
                        "id": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        }
                    },
                    "7": {
                        "$size": 64,
                        "size": 64,
                        "name": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        },
                        "id": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        }
                    },
                    "2": {
                        "$size": 64,
                        "size": 64,
                        "name": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        },
                        "id": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        }
                    },
                    "4": {
                        "$size": 64,
                        "size": 64,
                        "name": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        },
                        "id": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        }
                    },
                    "6": {
                        "$size": 64,
                        "size": 64,
                        "name": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        },
                        "id": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        }
                    },
                    "8": {
                        "$size": 64,
                        "size": 64,
                        "name": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        },
                        "id": {
                            "_sentinel": true,
                            "$type": "sentinel",
                            "$size": 32,
                            "size": 32
                        }
                    },
                    "summary": {
                        "length": 2,
                        "$type": "leaf",
                        "$size": 22,
                        "size": 22
                    }
                },
                "cast": {
                    "$size": 39,
                    "size": 39,
                    "0": ["person", "30002601"],
                    "1": ["person", "20018872"],
                    "2": ["person", "20060794"],
                    "3": ["person", "183425"],
                    "4": ["person", "20045112"],
                    "5": ["person", "20053381"],
                    "6": ["person", "79670"],
                    "7": ["person", "30070848"],
                    "8": ["person", "43305"],
                    "9": ["person", "20002118"],
                    "10": ["person", "17799"],
                    "11": ["person", "23560"],
                    "12": ["person", "30005975"],
                    "13": ["person", "20005901"],
                    "14": ["person", "20038110"],
                    "15": ["person", "30122090"],
                    "summary": {
                        "length": 16,
                        "$type": "leaf",
                        "$size": 23,
                        "size": 23
                    }
                },
                "seasonList": {
                    "$size": 32,
                    "size": 32,
                    "current": {
                        "_sentinel": true,
                        "$type": "sentinel",
                        "$size": 32,
                        "size": 32
                    }
                },
                "current": ["videos", "70301645"],
                "summary": {
                    "id": 70301645,
                    "type": "movie",
                    "isNSRE": false,
                    "isOriginal": false,
                    "$type": "leaf",
                    "$size": 69,
                    "size": 69
                },
                "episodeBadges": [],
                "title": "Guardians of the Galaxy",
                "synopsis": "Earth's heroes are mighty. The galaxy's heroes are a tree, a raccoon and a wise guy with a '70s mixtape.",
                "ancestor": ["videos", "70301645"],
                "interestingMoment": {
                    "$size": 89,
                    "size": 89,
                    "_665x375": {
                        "$size": 89,
                        "size": 89,
                        "webp": {
                            "url": "https://so-s.nflximg.net/soa4/859/140635859.webp",
                            "width": 608,
                            "height": 253,
                            "$type": "leaf",
                            "$size": 89,
                            "size": 89
                        }
                    }
                },
                "artWorkByType": {
                    "$size": 22,
                    "size": 22,
                    "BILLBOARD": {
                        "$size": 22,
                        "size": 22,
                        "_1280x720": {
                            "$size": 22,
                            "size": 22,
                            "webp": {
                                "url": null,
                                "$type": "leaf",
                                "$size": 22,
                                "size": 22
                            }
                        }
                    }
                },
                "BGImages": {
                    "$size": 1,
                    "size": 1,
                    "470": {
                        "$size": 1,
                        "size": 1,
                        "webp": [{
                            "url": "https://art-s.nflximg.net/2d2f0/ad82718fe9efca2bca80ad0c57b4fa72ca92d2f0.webp",
                            "width": 848,
                            "height": 477,
                            "focalPoint": "{\"x\":0.683854,\"y\":0.201852}"
                        }, {
                            "url": "https://so-s.nflximg.net/soa2/817/140630817.webp",
                            "width": 1152,
                            "height": 480,
                            "focalPoint": null
                        }, {
                            "url": "https://so-s.nflximg.net/soa5/366/140608366.webp",
                            "width": 1152,
                            "height": 480,
                            "focalPoint": null
                        }]
                    }
                }
            }
        },
        "genres": {
            "$size": 4,
            "size": 4,
            "1365": {
                "$size": 2,
                "size": 2,
                "id": 1365,
                "name": "Action & Adventure"
            },
            "7442": {
                "$size": 2,
                "size": 2,
                "id": 7442,
                "name": "Adventures"
            }
        },
        "person": {
            "$size": 32,
            "size": 32,
            "30002601": {
                "$size": 2,
                "size": 2,
                "id": 30002601,
                "name": "Chris Pratt"
            },
            "20018872": {
                "$size": 2,
                "size": 2,
                "id": 20018872,
                "name": "Zoe Saldana"
            },
            "20060794": {
                "$size": 2,
                "size": 2,
                "id": 20060794,
                "name": "Dave Bautista"
            },
            "183425": {
                "$size": 2,
                "size": 2,
                "id": 183425,
                "name": "Vin Diesel"
            },
            "20045112": {
                "$size": 2,
                "size": 2,
                "id": 20045112,
                "name": "Bradley Cooper"
            },
            "20053381": {
                "$size": 2,
                "size": 2,
                "id": 20053381,
                "name": "Lee Pace"
            },
            "79670": {
                "$size": 2,
                "size": 2,
                "id": 79670,
                "name": "Michael Rooker"
            },
            "30070848": {
                "$size": 2,
                "size": 2,
                "id": 30070848,
                "name": "Karen Gillan"
            },
            "43305": {
                "$size": 2,
                "size": 2,
                "id": 43305,
                "name": "Djimon Hounsou"
            },
            "20002118": {
                "$size": 2,
                "size": 2,
                "id": 20002118,
                "name": "John C. Reilly"
            },
            "17799": {
                "$size": 2,
                "size": 2,
                "id": 17799,
                "name": "Glenn Close"
            },
            "23560": {
                "$size": 2,
                "size": 2,
                "id": 23560,
                "name": "Benicio Del Toro"
            },
            "30005975": {
                "$size": 2,
                "size": 2,
                "id": 30005975,
                "name": "Peter Serafinowicz"
            },
            "20005901": {
                "$size": 2,
                "size": 2,
                "id": 20005901,
                "name": "Sean Gunn"
            },
            "20038110": {
                "$size": 2,
                "size": 2,
                "id": 20038110,
                "name": "Christopher Fairbank"
            },
            "30122090": {
                "$size": 2,
                "size": 2,
                "id": 30122090,
                "name": "Laura Haddock"
            }
        }
    },
    "paths": [
        ["videos", "70301645", ["maturity", "bookmarkPosition", "runtime", "requestId", "availability", "watched", "regularSynopsis", "queue", "evidence", "episodeCount", "info", "seasonCount", "releaseYear", "userRating", "numSeasonsLabel"]],
        ["videos", "70301645", "trailers", "summary"],
        ["videos", "70301645", "bb2OGLogo", "_400x90", "webp"],
        ["videos", "70301645", "genres", {
                "from": 0,
                "to": 2
            },
            ["id", "name"]
        ],
        ["videos", "70301645", "genres", "summary"],
        ["videos", "70301645", "tags", {
                "from": 0,
                "to": 9
            },
            ["id", "name"]
        ],
        ["videos", "70301645", "tags", "summary"],
        ["videos", "70301645", "cast", {
                "from": 0,
                "to": 5
            },
            ["id", "name"]
        ],
        ["videos", "70301645", "cast", "summary"],
        ["videos", "70301645", "seasonList", "current", "summary"],
        ["videos", "70301645", "current", ["title", "bookmarkPosition", "summary", "synopsis", "runtime", "episodeBadges"]],
        ["videos", "70301645", "current", "ancestor", "summary"],
        ["videos", "70301645", "current", "interestingMoment", "_665x375", "webp"],
        ["videos", "70301645", "artWorkByType", "BILLBOARD", "_1280x720", "webp"],
        ["videos", "70301645", "BGImages", "470", "webp"]
    ]
}
```
