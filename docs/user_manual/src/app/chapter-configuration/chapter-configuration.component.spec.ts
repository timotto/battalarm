import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ChapterConfigurationComponent } from './chapter-configuration.component';

describe('ChapterConfigurationComponent', () => {
  let component: ChapterConfigurationComponent;
  let fixture: ComponentFixture<ChapterConfigurationComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ChapterConfigurationComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ChapterConfigurationComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
